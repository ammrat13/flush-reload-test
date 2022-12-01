{.compile: "./primitives.s".}
proc rdtsc*(): uint32 {.importc.}
proc probe*(a: ptr): uint32 {.importc.}

when isMainModule:
  var x: uint64 = 5
  while true:
    echo probe(addr(x))
