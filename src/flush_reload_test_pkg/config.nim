import std/strutils
import std/parseopt


type Config* = ref object
  ## The configuration for this run of the program. Contains the file we are to
  ## load and the offset into the file we are to continuously probe.
  iterations*: uint64
  fname*: string
  offset*: uint64

proc `$`*(x: Config): string =
  ## Convenience method to print a `Config <#Config>`_
  if x == nil:
    return "(nil)"
  return "Config(fname: \"" & x.fname & "\", offset: " & $x.offset & ")"


proc get_config*(): Config =
  ## Parse a configuration from the command-line. Expected format is:
  ## ```
  ## $ ./flush_reload_test <iterations> <filename> <offset>
  ## ```

  # Allocate memory for the result
  result = Config()
  # Count what position we are in for the arguments
  var argc = 0

  for kind, key, val in getopt():
    # Ignore everything but arguments
    if kind in {cmdLongOption, cmdShortOption, cmdEnd}:
      raise newException(ValueError, "Could not parse command-line options")

    # Different parse logic for different arguments
    case argc
    of 0:
      result.iterations = parseBiggestUInt key
    of 1:
      result.fname = key
    of 2:
      result.offset = parseBiggestUInt key
    else:
      raise newException(ValueError, "Too many arguments")

    # Increment the argument count at the very end
    argc += 1

  # Check we got as many as we needed
  assert(argc == 3, "Too few arguments")
