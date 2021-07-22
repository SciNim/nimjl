import ../types
import ../functions
import ./interop

import std/macros

import ../sugar/macro_index_utils

# TODO make Nim views and Julia views correspond
{.experimental: "views".}


# You may be wondering why desugar Array is almost a duplicate as a desugar Value.
# Devil's is in the details and there are small, but key, difference between the two.
# Desugar for Array iterate over dimensions, while indexing for value do not (can't have multi-dimensionnal value indexed AFAIK)
# This changes lastindex syntax and desugar and make factorizing not really worth it
macro desugar[T](x: JlArray[T], args: untyped): void =
  ## Transform all syntactic sugar in arguments to integer or slices

  # echo "\n------------------\nOriginal tree"
  # echo args.treerepr
  # echo args.repr
  # echo "----------------------"

  var r = newNimNode(nnkArglist)
  # for nnk in children(args):
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

    # Node is of the form "_ `op`^*"
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

    elif nnk0_inf_dotdot and nnk1_joker and nnk21_joker: #and nnk20_bar_all :
      ## [_.._|2, 3] into [0..^1|2, 3]
      ## [_.._|+2, 3] into [0..^1|2, 3]
      ## [_.._|-2 doesn't make sense and will throw out of bounds
      # r.add(infix(newIntLitNode(0), "..^", infix(newIntLitNode(1), $nnk[2][0], nnk[2][2])))
      let step = nnk[2][2]
      r.add(
        quote do:
        makerange(firstindex(`x`, `ndim`), lastindex(`x`, `ndim`), `step`)
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
          makerange(firstindex(`x`, `ndim`), `stop`, `step`)
        )
      elif nnk0_inf_dotdot_inf:
        let step = nnk[2][2]
        r.add(
          quote do:
          makerange(firstindex(`x`, `ndim`), `stop`-1, `step`)
        )
      elif nnk0_inf_dotdot_alt:
        let step = nnk[2][2]
        r.add(
          quote do:
          makerange(firstindex(`x`, `ndim`), lastindex(`x`, `ndim`)-`stop`+1, `step`)
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
          makerange(firstindex(`x`, `ndim`), `stop`, `step`)
        )
      elif nnk0_inf_dotdot_inf:
        let step = nnk[2][2]
        r.add(
          quote do:
          makerange(firstindex(`x`, `ndim`), `stop`-1, `step`)
        )
      elif nnk0_inf_dotdot_alt:
        let step = nnk[2][2]
        r.add(
          quote do:
          makerange(firstindex(`x`, `ndim`), lastindex(`x`, `ndim`)-`stop`+1, `step`)
        )

    elif nnk0_inf_dotdot and nnk2_joker:
      ## [1.._, 3] into [1..^1|1, 3]
      # r.add(infix(nnk[1], "..^", infix(newIntLitNode(1), "|", newIntLitNode(1))))
      let start = nnk[1]
      let step = 1
      r.add(
        quote do:
        makerange(`start`, lastindex(`x`, `ndim`), `step`)
      )

    elif nnk0_inf_dotdot and nnk20_bar_pos and nnk21_joker:
      ## [1.._|1, 3] into [1..^1|1, 3]
      ## [1.._|+1, 3] into [1..^1|1, 3]
      # r.add(infix(nnk[1], "..^", infix(newIntLitNode(1), "|", nnk[2][2])))
      let start = nnk[1]
      let step = nnk[2][2]
      r.add(
        quote do:
        makerange(`start`, lastindex(`x`, `ndim`), `step`)
      )
    elif nnk0_inf_dotdot and nnk20_bar_min and nnk21_joker:
      ## Raise error on [5.._|-1, 3]
      raise newException(IndexDefect, "Please use explicit end of makerange instead of `_` when the steps are negative")

    elif nnk0_inf_dotdot_all and nnk10_hat and nnk20_bar_all:
      # We can skip the parenthesis in the AST
      ## [^1..2|-1, 3] into [^(1..2|-1), 3]
      # r.add(prefix(infix(nnk[1][1], $nnk[0], nnk[2]), "^"))
      let start = nnk[1][1]
      let stop = nnk[1][2]
      let step = nnk[2] # Should be < 0

      r.add(
        quote do:
        makerange(`start`, `stop`, `step`)
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
        makerange(lastindex(`x`, `ndim`)-`start`+1, `stop`, `step`)
      )

    elif nnk0_inf_dotdot_all and nnk20_bar_all:
      ## [1..10|1] as is
      ## [1..^10|1] as is
      let start = nnk[1]
      let stop = nnk[2][1]
      let step = nnk[2][2]

      if nnk0_inf_dotdot:
        r.add(
          quote do:
          makerange(`start`, `stop`, `step`)
        )
      elif nnk0_inf_dotdot_inf:
        let step = nnk[2][2]
        r.add(
          quote do:
          makerange(`start`, `stop`-1, `step`)
        )
      elif nnk0_inf_dotdot_alt:
        let step = nnk[2][2]
        r.add(
          quote do:
          makerange(`start`, lastindex(`x`, `ndim`)-`stop`+1, `step`)
        )

    elif nnk0_inf_dotdot_all:
      ## [1..10, 3] to [1..10|1, 3]
      ## [1..^10, 3] to [1..^10|1, 3]
      ## [1..<10, 3] to [1..<10|1, 3]
      # r.add(infix(nnk[1], $nnk[0], infix(nnk[2], "|", newIntLitNode(1))))
      let start = nnk[1]
      let stop = nnk[2]
      if nnk0_inf_dotdot:
        r.add(
          quote do:
          makerange(`start`, `stop`)
        )
      elif nnk0_inf_dotdot_inf:
        r.add(
          quote do:
          makerange(`start`, `stop`-1)
        )
      elif nnk0_inf_dotdot_alt:
        r.add(
          quote do:
          makerange(`start`, lastindex(`x`, `ndim`)-`stop`+1)
        )

    elif nnk0_pre_hat:
      ## [^2, 3] into [^2..^2|1, 3]
      # r.add(prefix(infix(nnk[1], "..^", infix(nnk[1], "|", newIntLitNode(1))), "^"))
      let stop = nnk[1]
      r.add(
        quote do:
        lastindex(`x`, `ndim`) - `stop` + 1
      )

    else:
      r.add(nnk)

  # echo "\nAfter modif"
  # echo r.treerepr
  # echo r.repr
  # echo "======================"
  # echo r.astGenRepr
  return r

# [] Index at 1
macro op_square_bracket_slice*[T](x: JlArray[T], args: varargs[untyped]): untyped =
  let new_args = getAST(desugar(x, args))
  result = quote do:
    jlCall("getindex", `x`, `new_args`)

template `[]`*[T](x: JlArray[T], args: varargs[untyped]): JlArray[T] =
  op_square_bracket_slice(x, args).toJlArray(typedesc[T])

macro op_square_bracket_view*[T](x: var JlArray[T], args: varargs[untyped]): untyped =
  let new_args = getAST(desugar(x, args))
  result = quote do:
    # Using view is bugger and not clear at all.
    # Drop it for now
    jlCall("view", `x`, `new_args`)

template `[]`*[T](x: var JlArray[T], args: varargs[untyped]): JlArray[T] =
  op_square_bracket_slice(x, args).toJlArray(typedesc[T])

macro `[]=`*[T](x: var JlArray[T], args: varargs[untyped]) =
  var tmp = args
  # See for why val has to be in varargs
  # https://github.com/nim-lang/Nim/issues/5855
  let val = tmp[tmp.len - 1]
  tmp.del(tmp.len-1)
  let new_args = getAST(desugar(x, tmp))
  result = quote do:
    discard jlCall("setindex!", `x`, `val`, `new_args`)
