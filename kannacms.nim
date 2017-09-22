import jester, asyncdispatch, asyncnet
import httpcore, strutils
import os, utils, md5

include "content.tmpl"
include "404.tmpl"

const baseTitle = "clang.moe"

proc match(request: Request, response: Response): Future[bool] {.async, gcsafe.} = 
  result = true
  let path = request.pathInfo
  echo path
  if path.startsWith("/css/") or path.startsWith("/js/"):
    result = false
  else:
    let basePath =
      if path[path.high] == '/': path & "index"
      elif path.endsWith(".html"): path[^5 .. ^1]
      else: path

    let filePath = "content" / basePath & ".rst"
    if existsFile(filePath):
      let data = readFile(filePath)
      let hashed = getMD5(data)
      if request.headers.hasKey("If-None-Match") and request.headers["If-None-Match"] == hashed:
        await response.send(Http304, newStringTable(), "")
      else:
        let headers = {"Content-Type": "text/html;charset=utf-8", "ETag": hashed}.newStringTable()
        let title = 
          if basePath[1 .. ^1] == "index": baseTitle
          else: basePath[1 .. ^1] & " - " & baseTitle
        await response.send(Http200, headers, genContent(title, data.rstToHTML))
    else:
      let headers = {"Content-Type": "text/html;charset=utf-8"}.newStringTable()
      await response.send(Http404, headers, genNotFound(baseTitle, path))
    response.client.close()

jester.serve(match)
runForever()