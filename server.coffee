http      = require("http")
fs        = require("fs")
socketio  = require("socket.io")

port = process.env.PORT || 5000

server = http.createServer((request, response) ->
  switch request.url
    when "/", "/index.html"
      response.writeHead(200, {"Content-Type": "text/html"})
      response.write(fs.readFileSync("index.html"))
    when "/script.js"
      response.writeHead(200, {"Content-Type": "text/javascript"})
      response.write(fs.readFileSync("client.js"))
  response.end()
  return
).listen(port, ->
  console.log("Listening on %d.", port)
  return
)

io = socketio.listen(server)

idCounter = 0

player = size = board = turn = null

setTimeout(->
  reset()
  return
)

io.on("connection", (socket) ->

  socket.on("login", (name) ->

    id = idCounter++

    if name == ""
      name = "Anonymous" + String(id)
      socket.emit("set name", name)

    draw()
    sendMessage("[ " + name + " log in ]")

    socket.on("disconnect", ->
      sendMessage("[ " + name + " log out ]")
      return
    )

    socket.on("click", (x, y) ->
      if turn? and player[turn] == id and 0 <= x < size and 0 <= y < size
        put(x, y)
      return
    )

    socket.on("entry", ->
      if not player.black?
        player.black = id
        sendMessage("[ " + name + " play as black ]")
      else if not player.white?
        player.white = id
        sendMessage("[ " + name + " play as white ]")
      return
    )

    socket.on("reset", ->
      reset()
      draw()
      sendMessage("[ " + name + " reset ]")
      return
    )

    socket.on("chat", (text) ->
      sendMessage(name + ": " + text)
      return
    )

    return
  )

  return
)

sendMessage = (text) ->
  io.sockets.emit("message", text)
  return

draw = ->
  io.sockets.emit("draw", size, board)
  return

reset = ->
  player = {}
  size = 8
  board = []
  for x in [0 ... size]
    board[x] = []
    for y in [0 ... size]
      board[x][y] = "blank"
  board[3][3] = "black"
  board[3][4] = "white"
  board[4][3] = "white"
  board[4][4] = "black"
  turn = "black"
  return

gameOver = ->
  turn = null
  blackCnt = 0
  whiteCnt = 0
  for x in [0 ... size]
    for y in [0 ... size]
      switch board[x][y]
        when "black"
          blackCnt++
        when "white"
          whiteCnt++
  sendMessage("[ black " + String(blackCnt) + "-" + String(whiteCnt) + " white ]")
  return

switchTurn = ->
  switch turn
    when "black"
      turn = "white"
    when "white"
      turn = "black"
  return

put = (x, y) ->

  invs = invertibles(x, y)

  if invs.length == 0
    return

  board[x][y] = turn
  for p in invs
    board[p.x][p.y] = turn

  draw()
  sendMessage("[ " + turn + " " + String(x) + " " + String(y) + " ]")

  switchTurn()

  if hasToPass()
    sendMessage("[ " + turn + " pass ]")
    switchTurn()
    if hasToPass()
      sendMessage("[ " + turn + " pass ]")
      gameOver()

  return

hasToPass = ->
  for x in [0 ... size]
    for y in [0 ... size]
      if invertibles(x, y).length > 0
        return false
  return true

invertibles = (x, y) ->
  if board[x][y] != "blank"
    return []
  accum = []
  for d in dirs
    temp = []
    xx = x
    yy = y
    while true
      xx += d.x
      yy += d.y
      if not (0 <= xx < size and 0 <= yy < size)
        break
      else if board[xx][yy] == "blank"
        break
      else if board[xx][yy] == turn
        accum = accum.concat(temp)
        break
      else
        temp.push({x: xx, y: yy})
  return accum

dirs = [
  {x: -1, y: -1}
  {x: -1, y:  0}
  {x: -1, y: +1}
  {x:  0, y: -1}
  {x:  0, y: +1}
  {x: +1, y: -1}
  {x: +1, y:  0}
  {x: +1, y: +1}
]
