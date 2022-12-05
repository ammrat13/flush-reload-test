import flush_reload_test_pkg/primitives

when isMainModule:

  let s = rdtsc()
  spin(2500)
  let c = rdtsc()

  echo c - s
