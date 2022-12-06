import std/bitops
import std/memfiles
import flush_reload_test_pkg/primitives
import flush_reload_test_pkg/config


when isMainModule:

  # Parse the configuration from the command-line
  let c = get_config()
  echo "Running with configuration: " & $c

  # Open the file
  let fh = memfiles.open(c.fname)
  echo "Opened " & c.fname

  # Check that the offsets are in bounds
  assert(
    bitor(c.offset, 0x1f) < cast[uint64](fh.size),
    "Offset too big"
  )
  # Get an array into the file
  # Also get the address to probe
  let fa = cast[ptr UncheckedArray[uint8]](fh.mem)
  let a = addr fa[c.offset]

  # Probe as long as we're asked
  var res = newSeqOfCap[uint32](c.iterations)
  for _ in 1..c.iterations:
    res.add(probe(a))

  for x in res:
    echo x
