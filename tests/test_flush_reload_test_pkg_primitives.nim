import std/unittest
import flush_reload_test_pkg/primitives


suite "primitives":

  test "rdtsc_smoke":
    ## Assert that rdtsc returns a sensible number
    ## That number should be in the range [0, 2**32). If it's not, we probably
    ## messed up the assembly somehow.
    let ret = rdtsc()
    check ret >= 0'u32
    check ret <= 0xffff_ffff'u32

  test "rdtsc_increasing":
    ## The timestamp counter should never decrease
    ## Check this property by calling the function twice, then subtracting the
    ## results. This could lead to overflow, so make sure to disable those
    ## checks. Also, do it multiple times just in case.
    for _ in 1..100:
      let r1 = rdtsc()
      let r2 = rdtsc()
      # Remember unsigned numbers have no overflow check
      let d: int32 = cast[int32](r2 - r1)
      check d > 0

  test "probe_smoke":
    ## Assert that we can probe an address and that we get reasonable results
    ## It's okay that x is on the stack here. It will be in the cache initially,
    ## but that's okay for a sanity check.
    var x: uint64
    let ret = probe x.addr
    check ret < 500

  test "probe_cache":
    ## Assert that the probe function behaves appropriately on cached data
    ## Here, we must allocate x on the heap. Otherwise, the stack will be pulled
    ## back into the cache pretty much as soon as it's (forcibly) evicted.
    let x: ref uint64 = new uint64
    for _ in 1..100:
      # Flush the variable from the cache, then probe
      discard probe x
      let r1 = probe x
      # Touch the value, then probe
      x[] = 0
      let r2 = probe x
      # Assert correct behavior
      check r1 > r2
