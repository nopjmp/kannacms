import os, packages/docutils/rst, packages/docutils/rstgen, strtabs, strutils, pegs

var docConfig: StringTableRef

docConfig = rstgen.defaultConfig()
docConfig["doc.smiley_format"] = "/images/smilieys/$1.png"

# [^[:alnum:]\~\-\./]
proc normalizePath*(path: string): string =
    result = strutils.replace(path, "..")
    result = pegs.replace(result, peg"[^a-zA-Z0-9\-\.\~/]")

proc rstToHTML*(content: string): string =
    result = rstgen.rstToHtml(content, {roSupportSmilies, roSupportMarkdown}, docConfig)