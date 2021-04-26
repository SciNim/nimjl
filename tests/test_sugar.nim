import nimjl


proc main() =
  jlVmInit()
  discard jlMain.println(@[1, 2, 3])
  jlVmExit(0)

main()
