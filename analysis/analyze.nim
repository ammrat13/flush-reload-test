import std/streams
import std/parsecsv

import analyze_pkg/config


proc do_parse*(fh: sink Stream, c: Config): string =

  var fr: CsvParser
  fr.open(fh, "INPUT")

  return "aaa"


when isMainModule:
  let c  = get_config()
  let fh = openFileStream(c.fname)
  echo do_parse(fh, c)
