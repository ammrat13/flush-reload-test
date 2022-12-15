import std/strutils
import std/parseopt


type Config* = ref object

  fname*: string

  hit_threshold_cycles: uint32
  squ_threshold_slices: uint
  mul_threshold_cycles: uint32


proc get_config*(): Config =

  result = Config()
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

  if result.fname.len == 0:
    raise newException(ValueError, "No filename")
