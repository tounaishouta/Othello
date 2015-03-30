port = process.env.PORT || 5000

server = require("http").createServer((request, response) ->
  switch request.url
    when "/1234"
      response.writeHead(200, { "Content-Type": "text/html" })
      response.write(require("fs").readFileSync("index.html", "utf-8"))
    when "/client.js"
      response.writeHead(200, { "Content-Type": "text/javascript" })
      response.write(require("fs").readFileSync("client.js", "utf-8"))
  response.end()
  return
).listen(port, ->
  console.log("Listening on %d", port)
  return
)

playerExists = { "black": false, "white": false }

io = require("socket.io").listen(server)

io.on("connection", (socket) ->

  if not playerExists.black
    color = "black"
    playerExists.black = true
    socket.emit("message", "You play black.")
  else if not playerExists.white
    color = "white"
    playerExists.white = true
    socket.emit("message", "You play white.")
  else
    color = "audience"
    socket.emit("message", "You are audience.")

  socket.emit("draw", getBoard())

  console.log("connection", color)

  socket.on("disconnect", ->
    playerExists[color] = false
    io.sockets.emit("message", color + " disconnected.")
    console.log("disconnect", color)
    return
  )

  socket.on("message", (text) ->
    io.sockets.emit("message", text)
    console.log("message", text)
    return
  )

  socket.on("click", (i, j) ->
    switch color
      when "black"
        array[i][j] = "x"
      when "white"
        array[i][j] = "o"
    io.sockets.emit("draw", getBoard())
    return
  )

  return
)

size = 8

array = []
for i in [0 ... size]
  array[i] = []
  for j in [0 ... size]
    array[i][j] = "."
array[3][3] = "x"
array[3][4] = "o"
array[4][3] = "o"
array[4][4] = "x"

getBoard = ->
  return {
    size: size
    array: array
  }
