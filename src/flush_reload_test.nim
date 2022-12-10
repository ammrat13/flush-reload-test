import std/bitops
import std/strutils
import std/sequtils
import std/memfiles
import flush_reload_test_pkg/primitives
import flush_reload_test_pkg/config


when isMainModule:

  # Parse the configuration from the command-line
  let c = get_config()
  stderr.writeLine "Running with configuration: " & $c

  # Open the file
  let fh = memfiles.open(c.fname)
  stderr.writeLine "Opened " & c.fname

  # Check that all the offsets are in bounds
  for o in c.offsets:
    if bitor(o, 63) >= cast[uint64](fh.size):
      raise newException(ValueError, "Offset " & $o & " too big")

  # Get an array into the file
  let fa = cast[ptr UncheckedArray[char]](fh.mem)
  # Get all the addresses to probe
  let addrs = c.offsets.map(proc(o: uint64): pointer = addr fa[o])

  # Allocate memory for the result
  # Do it in one shot
  var results_raw = newSeqOfCap[uint32](
    c.iters * (1 + cast[uint64](c.offsets.len))
  )
  stderr.writeLine "Allocated space for results"

  stderr.writeLine ""
  stderr.writeLine "Probing..."
  # Performance is critical during the probe
  # Optimize in release mode
  when defined(release):
    {.push checks: off, assertions: off, optimize: speed .}

  # Actually do the probe
  for _ in 1..c.iters:
    let start = rdtsc()
    results_raw.add(start)
    for a in addrs:
      results_raw.add(probe a)
    spin(c.delay, start)

  # Pop the optimization pragmas
  when defined(release):
    {.pop.}
  stderr.writeLine "Done probing"

  # Process results
  let results = results_raw.distribute(c.iters)

  # Write the results
  stderr.writeLine ""
  stderr.writeLine "Writing file..."
  echo "tsc," & c.offsets.map(proc(x: uint64): string = "off" & $x).join(",")
  for r in results:
    echo r.join(",")
  stderr.writeLine "Done writing file"
