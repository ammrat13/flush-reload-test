import std/unittest
import flush_reload_test


suite "primitives":

  test "rdtsc_smoke":
    ## Assert that rdtsc returns a sensible number
    ## That number should be in the range [0, 2**32). If it's not, we probably
    ## messed up the assembly somehow.
    let ret = rdtsc()
    check( ret >= 0'u32 )
    check( ret <= 0xffff_ffff'u32 )

  test "rdtsc_increasing":
    ## The timestamp counter should never decrease
    ## Check this property by calling the function twice, then subtracting the
    ## results. This could lead to overflow, so make sure to disable those
    ## checks. Also, do it multiple times just in case.
    for _ in 0..100:
      let r1 = rdtsc()
      let r2 = rdtsc()
      {.push overflowChecks: off.}
      let d: int32 = cast[int32](r2 - r1)
      {.pop.}
      check( d >= 0 )
      check( d >  0 )
