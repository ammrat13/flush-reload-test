import std/strutils
import std/streams
import std/parseopt
import std/parsecsv


type Config* = ref object
  ## Configuration for this run of the program. Has the name of the file to
  ## analyze as well as the thresholds to use in analysis.
  fname*: string ## The file to analyze
  hit_threshold_cycles: uint32 ## Anything under this is a cache hit
  squ_threshold_slices: uint   ## Any run longer than this is a square
  mul_threshold_cycles: uint32 ## Any gap longer than this is a multiply

proc get_config*(): Config =
  ## Parse a configuration from the command line. Expected format is:
  ## ```
  ## $ ./analyze -h:<hit> -s:<square> -m:<multiply> <filename>
  ## ```

  # Allocate memory for the result
  result = Config()
  # Set defaults
  result.hit_threshold_cycles = 250
  result.squ_threshold_slices = 3
  result.mul_threshold_cycles = 42_000

  for kind, key, val in getopt():

    if kind in {cmdLongOption, cmdShortOption}:
      case key
      of "hit-cycles","h":
        result.hit_threshold_cycles = cast[uint32](parseUInt val)
      of "squ-slices","s":
        result.squ_threshold_slices = parseUInt val
      of "mul-cycles","m":
        result.mul_threshold_cycles = cast[uint32](parseUInt val)

    if kind in {cmdArgument}:
      if result.fname.len == 0:
        result.fname = key
      else:
        raise newException(ValueError, "Too many arguments")

  # Check we got some file
  if result.fname.len == 0:
    raise newException(ValueError, "No filename")


proc do_parse*(fh: sink Stream, c: Config): string =

  var fr: CsvParser
  fr.open(fh, "INPUT")

  return "aaa"


when isMainModule:
  let c  = get_config()
  let fh = openFileStream(c.fname)
  echo do_parse(fh, c)
