{.compile: "./primitives.s".}
proc rdtsc(): uint64 {.importc.}

when isMainModule:
  while true:
    echo rdtsc()
