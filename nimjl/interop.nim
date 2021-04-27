import ./arrays
import ./config
import ./coretypes
import ./converttypes
import ./modfuncs

import private/jlarrays
import private/jlcores

import std/macros
import std/sequtils
import std/strformat

# Pretty syntax to call Julia function
type Julia* = object

proc init*(jl: type Julia) =
  jlVmInit()

proc exit*(jl: type Julia, exitcode: int = 0) =
  jlVmExit(exitcode.cint)

template `.`*(jl: type Julia, funcname: untyped, args: varargs[JlValue, toJlVal]): untyped =
  jlCall(astToStr(funcname), args)

template `.`*(jlmod: JlModule, funcname: untyped, args: varargs[JlValue, toJlVal]): untyped =
  jlCall(jlmod, astToStr(funcname), args)

# typeof is taken by Nim already
proc jltypeof*(jl: type Julia, x: JlValue): JlValue =
  jlCall("typeof", x)
# # This section is copyrighted from Arraymancer and Flambeau
# # ---------------------------------------------------------
# # Helpers proc
func getShape[T](s: openArray[T], parent_shape: seq[int] = @[]): seq[int] =
  ## Get the shape of nested seqs/arrays
  ## Important ⚠: at each nesting level, only the length
  ##   of the first element is used for the shape.
  ##   Ensure before or after that seqs have the expected length
  ##   or that the total number of elements matches the product of the dimensions.

  result = parent_shape
  result.add(s.len)

  when (T is seq|array):
    result = getShape(s[0], result)

macro getBaseType(T: typedesc): untyped =
  # Get the base T of a seq[T] input
  result = T.getTypeInst()[1]
  while result.kind == nnkBracketExpr and (
          result[0].eqIdent"seq" or result[0].eqIdent"array"):
    # We can also have nnkBracketExpr(Complex, float32)
    if result[0].eqIdent"seq":
      result = result[1]
    else: # array
      result = result[2]

iterator flatIter[T](s: openarray[T]): auto {.noSideEffect.} =
  ## Inline iterator on any-depth seq or array
  ## Returns values in order
  for item in s:
    when item is array|seq:
      for subitem in flatIter(item):
        yield subitem
    else:
      yield item

proc product[T](s: seq[T]): T =
  foldl(s, a*b)
# ---------------------------------------------------------
# End of copyrighted section

# TODO GC-Root this OR Disable Julia GC and works with Nim GC
proc toJlArrayView*[T](oa: openarray[T]): lent JlArray[T] =
  ## Interpret an openarray as a CPU Tensor
  ## Important:
  ##   the buffer is shared.
  ##   There is no copy but modifications are shared
  ##   and the view cannot outlive its buffer.
  ##
  ## Input:
  ##      - An array or a seq (can be nested)
  ## Result:
  ##      - A view Tensor of the same shape
  return jlArrayFromBuffer[T](oa)

proc toJlArray*[T: SomeNumber](oa: openarray[T]): JlArray[T] =
  ## Interpret an openarray as a CPU Tensor
  ##
  ## Input:
  ##      - An array or a seq
  ## Result:
  ##      - A view Tensor of the same shape
  # toArrayFromScalar[T](oa).toJlArray[T]()
  let shape = getShape(oa)
  let nbytes = shape.product()*(sizeof(T) div sizeof(byte))
  result = allocJlArray[T](shape)
  copyMem(unsafeAddr(result.getRawData()[0]), unsafeAddr(oa[0]), nbytes)

proc toJlArray*[T: seq|array](oa: openarray[T]): auto =
  ## Interpret an openarray as a CPU Tensor
  ##
  ## Input:
  ##      - An array or a seq
  ## Result:
  ##      - A view Tensor of the same shape
  let shape = getShape(oa)
  let nbytes = shape.product()*(sizeof(T) div sizeof(byte))
  type BaseType = getBaseType(T)
  var res = allocJlArray(shape, BaseType)
  copyMem(cast[ptr jl_array](res).jl_array_data(), unsafeAddr(oa[0]), nbytes)
  arrays.toJlArray(res, BaseType)

# TODO Test this
{.experimental: "views".}
proc JlColon(): JlValue =
  jlCall(JlBase, "Colon")

proc firstindex[T](x: JlArray[T], dim: int): int =
  jlCall("firstindex", x, dim).to(int)

proc lastindex[T](x: JlArray[T], dim: int): int =
  jlCall("lastindex", x, dim).to(int)

template makerange[T](x: JlArray[T], start, stop, step : int) : untyped =
  # Step = 0 is absurd
  var step = if step != 0: step else: 1
  if step > 0:
    toSeq(countup(start, stop, step))
  else:
    let step = abs(step)
    toSeq(countdown(stop, start, step))


# This comes from arraymancer
macro desugar*[T](x: JlArray[T], args: untyped): void =
  ## Transform all syntactic sugar in arguments to integer or SteppedSlices
  ## It will then be dispatched to "atIndex" (if specific integers)
  ## or "slicer" if there are SteppedSlices

  echo "\n------------------\nOriginal tree"
  echo args.treerepr
  var r = newNimNode(nnkArglist)
  var ndim = 0
  for nnk in children(args):
    inc(ndim)
    ###### Traverse top tree nodes and one-hot-encode the different conditions
    # Node is "_"
    let nnk_joker = eqIdent(nnk, "_")

    # Node is of the form "* .. *"
    let nnk0_inf_dotdot = (
      nnk.kind == nnkInfix and
      eqIdent(nnk[0], "..")
    )

    # Node is of the form "* ..< *" or "* ..^ *"
    let nnk0_inf_dotdot_inf = (
      nnk.kind == nnkInfix and eqIdent(nnk[0], "..<")
    )

    let nnk0_inf_dotdot_alt = (
      nnk.kind == nnkInfix and eqIdent(nnk[0], "..^")
    )

    # Node is of the form "* .. *", "* ..< *" or "* ..^ *"
    let nnk0_inf_dotdot_all = (
      nnk0_inf_dotdot or
      nnk0_inf_dotdot_alt or
      nnk0_inf_dotdot_inf
    )

    # Node is of the form "^ *"
    let nnk0_pre_hat = (
      nnk.kind == nnkPrefix and
      eqIdent(nnk[0], "^")
    )

    # Node is of the form "_ `op` *"
    let nnk1_joker = (
      nnk.kind == nnkInfix and
      eqIdent(nnk[1], "_")
    )

    # Node is of the form "_ `op` *"
    let nnk10_hat = (
      nnk.kind == nnkInfix and
      nnk[1].kind == nnkPrefix and
      eqident(nnk[1][0], "^")
    )

    # Node is of the form "* `op` _"
    let nnk2_joker = (
      nnk.kind == nnkInfix and
      eqident(nnk[2], "_")
    )

    # Node is of the form "* `op` * | *" or "* `op` * |+ *"
    let nnk20_bar_pos = (
      nnk.kind == nnkInfix and
      nnk[2].kind == nnkInfix and (
        eqident(nnk[2][0], "|") or
        eqIdent(nnk[2][0], "|+")
      )
    )

    # Node is of the form "* `op` * |- *"
    let nnk20_bar_min = (
      nnk.kind == nnkInfix and
      nnk[2].kind == nnkInfix and
      eqIdent(nnk[2][0], "|-")
    )

    # Node is of the form "* `op` * | *" or "* `op` * |+ *" or "* `op` * |- *"
    let nnk20_bar_all = nnk20_bar_pos or nnk20_bar_min

    # Node is of the form "* `op1` _ `op2` *"
    let nnk21_joker = (
      nnk.kind == nnkInfix and
      nnk[2].kind == nnkInfix and
      eqIdent(nnk[2][1], "_")
    )

    ###### Core desugaring logic
    if nnk_joker:
      ## [_, 3] into [Span, 3]
      r.add(
        quote do: JlColon()
      )

    elif nnk0_inf_dotdot and nnk1_joker and nnk2_joker:
      ## [_.._, 3] into [Span, 3]
      r.add(quote do: JlColon())

    elif nnk0_inf_dotdot and nnk1_joker and nnk20_bar_all and nnk21_joker:
      ## [_.._|2, 3] into [0..^1|2, 3]
      ## [_.._|+2, 3] into [0..^1|2, 3]
      ## [_.._|-2 doesn't make sense and will throw out of bounds
      # r.add(infix(newIntLitNode(0), "..^", infix(newIntLitNode(1), $nnk[2][0], nnk[2][2])))
      let step = nnk[2][2]
      r.add(
        quote do:
          makerange(`x`, firstindex(`x`, `ndim`), lastindex(`x`, `ndim`), `step`)
      )
    elif nnk0_inf_dotdot_all and nnk1_joker and nnk20_bar_all:
      ## [_..10|1, 3] into [0..10|1, 3]
      ## [_..^10|1, 3] into [0..^10|1, 3]   # ..^ directly creating SteppedSlices may introduce issues in seq[0..^10]
        # Furthermore ..^10|1, would have ..^ with precedence over |
      ## [_..<10|1, 3] into [0..<10|1, 3]
      # r.add(infix(newIntLitNode(0), $nnk[0], infix(nnk[2][1], $nnk[2][0], nnk[2][2])))
      let stop = nnk[2][1]
      let step = nnk[2][2]
      if nnk0_inf_dotdot:
        r.add(
          quote do:
            makerange(`x`, firstindex(`x`, `ndim`), `stop`, `step`)
        )
      elif nnk0_inf_dotdot_inf:
        let step = nnk[2][2]
        r.add(
          quote do:
            makerange(`x`, firstindex(`x`, `ndim`), `stop`-1, `step`)
        )
      elif nnk0_inf_dotdot_alt:
        let step = nnk[2][2]
        r.add(
          quote do:
            makerange(`x`, firstindex(`x`, `ndim`), lastindex(`x`, `ndim`)-`stop`+1, `step`)
        )

    elif nnk0_inf_dotdot_all and nnk1_joker:
      ## Identical as above but force step as 1
      ## [_..10, 3] into [0..10|1, 3]
      ## [_..^10, 3] into [0..^10|1, 3]   # ..^ directly creating SteppedSlices from int in 0..^10 may introduce issues in seq[0..^10]
      ## [_..<10, 3] into [0..<10|1, 3]
      # r.add(infix(newIntLitNode(0), $nnk[0], infix(nnk[2], "|", newIntLitNode(1))))
      let stop = nnk[2][1]
      let step = 1
      if nnk0_inf_dotdot:
        r.add(
          quote do:
            makerange(`x`, firstindex(`x`, `ndim`), `stop`, `step`)
        )
      elif nnk0_inf_dotdot_inf:
        let step = nnk[2][2]
        r.add(
          quote do:
            makerange(`x`, firstindex(`x`, `ndim`), `stop`-1, `step`)
        )
      elif nnk0_inf_dotdot_alt:
        let step = nnk[2][2]
        r.add(
          quote do:
            makerange(`x`, firstindex(`x`, `ndim`), lastindex(`x`, `ndim`)-`stop`+1, `step`)
        )

    elif nnk0_inf_dotdot and nnk2_joker:
      ## [1.._, 3] into [1..^1|1, 3]
      # r.add(infix(nnk[1], "..^", infix(newIntLitNode(1), "|", newIntLitNode(1))))
      let start = nnk[1]
      let step = 1
      r.add(
        quote do:
          makerange(`x`, `start`, lastindex(`x`, `ndim`), `step`)
      )

    # TODO Re-check this
    elif nnk0_inf_dotdot and nnk20_bar_pos and nnk21_joker:
      ## [1.._|1, 3] into [1..^1|1, 3]
      ## [1.._|+1, 3] into [1..^1|1, 3]
      # r.add(infix(nnk[1], "..^", infix(newIntLitNode(1), "|", nnk[2][2])))
      let start = nnk[1]
      let step = nnk[2][2]
      r.add(
        quote do:
          makerange(`x`, `start`, lastindex(`x`, `ndim`), `step`)
      )
    elif nnk0_inf_dotdot and nnk20_bar_min and nnk21_joker:
      ## Raise error on [5.._|-1, 3]
      raise newException(IndexDefect, "Please use explicit end of range " &
                       "instead of `_` " &
                       "when the steps are negative")
    elif nnk0_inf_dotdot_all and nnk10_hat and nnk20_bar_all:
      # We can skip the parenthesis in the AST
      ## [^1..2|-1, 3] into [^(1..2|-1), 3]
      # r.add(prefix(infix(nnk[1][1], $nnk[0], nnk[2]), "^"))
      let start = nnk[1][1]
      let stop = nnk[1][2]
      let step = nnk[2] # Should be < 0
      r.add(
        quote do:
          makerange(`x`, `start`, `stop`, `step`)
      )
    elif nnk0_inf_dotdot_all and nnk10_hat:
      # We can skip the parenthesis in the AST
      ## [^1..2*3, 3] into [^(1..2*3|1), 3]
      ## [^1..0, 3] into [^(1..0|1), 3]
      ## [^1..<10, 3] into [^(1..<10|1), 3]
      ## [^10..^1, 3] into [^(10..^1|1), 3]
      # r.add(prefix(infix(nnk[1][1], $nnk[0], infix(nnk[2], "|", newIntLitNode(1))), "^"))
      let start = nnk[1][1]
      let stop = nnk[1][2]
      let step = -1 # Should be < 0
      r.add(
        quote do:
          makerange(`x`, `start`, `stop`, `step`)
      )

    # TODO Finish this
    elif nnk0_inf_dotdot_all and nnk20_bar_all:
      ## [1..10|1] as is
      ## [1..^10|1] as is
      r.add(nnk)
    elif nnk0_inf_dotdot_all:
      ## [1..10, 3] to [1..10|1, 3]
      ## [1..^10, 3] to [1..^10|1, 3]
      ## [1..<10, 3] to [1..<10|1, 3]
      r.add(infix(nnk[1], $nnk[0], infix(nnk[2], "|", newIntLitNode(1))))
    elif nnk0_pre_hat:
      ## [^2, 3] into [^2..^2|1, 3]
      r.add(prefix(infix(nnk[1], "..^", infix(nnk[1], "|", newIntLitNode(1))), "^"))
    else:
      r.add(nnk)
  echo "\nAfter modif"
  echo r.treerepr
  # echo r.astGenRepr
  return r

macro `[]`*[T](x: JlArray[T], args: varargs[untyped]): untyped =
  let new_args = getAST(desugar(x, args))
  result = quote do:
    jlCall("getindex", `x`, `new_args`) #.toJlArray(T)

macro `[]`*[T](x: var JlArray[T], args: varargs[untyped]): untyped =
  let new_args = getAST(desugar(x, args))
  result = quote do:
    jlCall("view", `x`, `new_args`) #.toJlArray(T)

macro `[]=`*[T](x: JlArray[T], args: varargs[untyped], val: T) =
  let new_args = getAST(desugar(x, args))
  quote do:
    discard jlCall("setindex!", `x`, `val`, `new_args`) #.toJlArray(T)
