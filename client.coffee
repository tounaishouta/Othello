submit_login.disabled = false
text_login.readOnly   = false

form_login.onsubmit = (event) ->

  event.preventDefault()

  submit_login.disabled = true
  text_login.readOnly   = true

  socket = io.connect()

  socket.emit("login", text_login.value)

  socket.on("disconnect", ->
    writeText("[[[ disconnect ]]]")
    return
  )

  socket.on("set name", (name) ->
    text_login.value = name
    return
  )

  socket.on("draw", draw)

  socket.on("message", writeText)

  canvas.onclick = (event) ->
    x = Math.floor((event.clientX - offsetX) / scale)
    y = Math.floor((event.clientY - offsetY) / scale)
    socket.emit("click", x, y)
    return

  button_entry.onclick = (event) ->
    socket.emit("entry")
    return

  button_reset.onclick = (event) ->
    socket.emit("reset")
    return

  form_chat.onsubmit = (event) ->
    event.preventDefault()
    socket.emit("chat", text_chat.value)
    text_chat.value = ""
    return

  return

scale = offsetX = offsetY = null

draw = (size, board) ->

  canvas.width  = canvas.clientWidth
  canvas.height = canvas.clientHeight

  scale   = Math.floor(Math.min(canvas.width, canvas.height) / (size + 1))
  offsetX = Math.floor((canvas.width - size * scale) / 2)
  offsetY = Math.floor((canvas.height - size * scale) / 2)

  context = canvas.getContext("2d")
  context.setTransform(scale, 0, 0, scale, offsetX, offsetY)

  context.fillStyle = "#afa"
  context.fillRect(0, 0, size, size)

  context.beginPath()
  context.rect(0, 0, size, size)
  for i in [1 ... size]
    context.moveTo(i, 0)
    context.lineTo(i, size)
    context.moveTo(0, i)
    context.lineTo(size, i)
  context.lineJoin    = "round"
  context.lineWidth   = 0.01
  context.strokeStyle = "#5a5"
  context.stroke()

  for x in [0 ... size]
    for y in [0 ... size]
      switch board[x][y]
        when "black"
          context.beginPath()
          context.arc(x + 1/2, y + 1/2, 0.4, 0, 2 * Math.PI)
          context.fillStyle = "#000"
          context.fill()
        when "white"
          context.beginPath()
          context.arc(x + 1/2, y + 1/2, 0.4, 0, 2 * Math.PI)
          context.fillStyle = "#fff"
          context.fill()
          context.strokeStyle = "#000"
          context.stroke()

  window.onresize = ->
    draw(size, board)
    return

  return

writeText = (text) ->
  div_stdout.appendChild(document.createTextNode(text))
  div_stdout.appendChild(document.createElement("br"))
  div_stdout.scrollTop = div_stdout.scrollHeight
  return
