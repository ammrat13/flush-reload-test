import std/strutils
import std/sequtils
import std/streams
import std/parseopt
import std/parsecsv


type Config = ref object
  ## Configuration for this run of the program. Has the name of the file to
  ## analyze as well as the thresholds to use in analysis.
  fname*: string ## The file to analyze
  hit_threshold_cycles: uint32 ## Anything under this is a cache hit
  squ_threshold_slices: uint   ## Any run longer than this is a square
  mul_threshold_cycles: uint32 ## Any gap longer than this is a multiply
  filter_width: uint ## Supress spurious by looking in this range

proc get_config(): Config =
  ## Parse a configuration from the command line. Expected format is:
  ## ```
  ## $ ./analyze -h:<hit> -s:<square> -m:<multiply> -f:<filter_width> <filename>
  ## ```

  # Allocate memory for the result
  result = Config()
  # Set defaults
  result.hit_threshold_cycles = 250
  result.squ_threshold_slices = 3
  result.mul_threshold_cycles = 42_000
  result.filter_width = 1

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


# ------------------------------------------------------------------------------


type TimeSlice = object
  ## Represents an individual timeslice in the CSV file
  tsc: uint32 # The timestamp counter at that timeslice
  hit: bool   # Whether we had a hit on the square line

proc `$`(x: TimeSlice): string =
  return "TimeSlice(" &
    "tsc: " & $x.tsc & ", " &
    "hit: " & $x.hit &
  ")"


proc trim[T](s: seq[T], keep: proc(x: T): bool): seq[T] =
  # Get index to cut from before
  var i_b = 0
  while i_b < s.len() and not keep(s[i_b]):
    i_b += 1
  if i_b == s.len():
    return @[]
  # Same for after
  var i_a = s.len() - 1
  while i_a >= 0 and not keep(s[i_a]):
    i_a -= 1
  if i_a < 0:
    return @[]
  # Return the slice
  return s[i_b..i_a]

proc main*(fh: sink Stream, c: Config): string =

  # Parse the input as a CSV
  var fr: CsvParser
  fr.open(fh, "INPUT")

  # Read out all the TimeSlices
  var slices = newSeq[TimeSlice](0)
  fr.readHeaderRow()
  while fr.readRow():
    let tsc = cast[uint32](parseUInt fr.rowEntry("tsc"))
    let h_t = parseBiggestUInt fr.rowEntry("off662000")
    slices.add TimeSlice(
      tsc: tsc,
      hit: h_t < c.hit_threshold_cycles
    )

  # Do filtering
  for i in c.filter_width .. cast[uint](slices.len()) - c.filter_width - 1:
    # Get the indices for before and after
    let check_idxs =
      toSeq((i - c.filter_width) .. (i-1)) &
      toSeq((i+1) .. (i + c.filter_width))
    # Check if they agree
    let all_t = check_idxs.all(proc(j: uint): bool = slices[j].hit)
    let all_f = check_idxs.all(proc(j: uint): bool = not slices[j].hit)
    # Set this as needed
    if all_t:
      slices[i].hit = true
    if all_f:
      slices[i].hit = false

  # Get rid of unneeded entries on start and end
  slices = trim(slices, proc(x: TimeSlice): bool = x.hit)

  return $slices.len()


when isMainModule:
  let c  = get_config()
  let fh = openFileStream(c.fname)
  echo main(fh, c)
