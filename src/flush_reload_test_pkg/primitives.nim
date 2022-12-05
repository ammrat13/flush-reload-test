{.compile: "./primitives.s".}
proc rdtsc*(): uint32 {.importc.}
proc probe*(a: ref or ptr): uint32 {.importc.}

proc spin*(n: uint32) =
  let start_time = rdtsc()
  while rdtsc() - start_time < n:
    continue
