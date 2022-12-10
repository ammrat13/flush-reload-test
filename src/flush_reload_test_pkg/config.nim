import std/strutils
import std/parseopt


type Config* = ref object
  ## The configuration for this run of the program. Contains the file we are to
  ## load and the offset into the file we are to continuously probe.

  fname*: string        ## The file on which to probe
  offsets*: seq[uint64] ## The offsets into the file to probe

  delay*: uint32 ## How long to wait between probes
  iters*: uint64 ## How many times to probe all the offsets

proc `$`*(x: Config): string =
  ## Convenience method to print a `Config <#Config>`_
  if x == nil:
    return "(nil)"
  return "Config(" &
    "fname: \"" & x.fname & "\", " &
    "offsets: " & $x.offsets & ", " &
    "delay: " & $x.delay & ", " &
    "iters: " & $x.iters &
    ")"


proc get_config*(): Config =
  ## Parse a configuration from the command-line. Expected format is:
  ## ```
  ## $ ./flush_reload_test -d:<delay> -n:<iterations> <filename> <offset> <offset> ...
  ## ```

  # Allocate memory for the result
  result = Config()
  # Set defaults
  result.delay = 2500
  result.iters = 1000000

  for kind, key, val in getopt():

    # Deal with options
    if kind in {cmdLongOption, cmdShortOption}:
      case key
      of "delay","d":
        result.delay = cast[uint32](parseBiggestUInt val)
      of "iterations","n":
        result.iters = parseBiggestUInt val
      else:
        raise newException(ValueError, "Invalid option: " & key)

    # Parse arguments
    # Remember that the first argument is the filename
    if kind in {cmdArgument}:
      if result.fname.len == 0:
        result.fname = key
      else:
        result.offsets.add parseBiggestUInt(key)

  # Assert we got enough arguments
  if result.fname.len == 0:
    raise newException(ValueError, "No filename")
  if result.offsets.len == 0:
    raise newException(ValueError, "No offsets")
