socket = io.connect()

socket.on("connect", -> writeMessage("connect"))
socket.on("disconnect", -> writeMessage("disconnect"))

socket.on("draw", (data) -> draw(data))
socket.on("message", (text) -> writeMessage(text))

size = array = canvas = scale = offsetX = offsetY = context = null

draw = (data) ->

  if data?
    if data.size?
      size = data.size
    if data.array?
      array = data.array

  canvas = document.getElementById("canvas")
  canvas.width = canvas.clientWidth
  canvas.height = canvas.clientHeight

  scale = Math.floor(Math.min(canvas.width, canvas.height) / (size + 2))
  offsetX = Math.floor((canvas.width - size * scale) / 2)
  offsetY = Math.floor((canvas.height - size * scale) / 2)

  context = canvas.getContext("2d")
  context.setTransform(scale, 0, 0, scale, offsetX, offsetY)

  context.fillStyle = "#afa"
  context.fillRect(0, 0, size, size)

  context.strokeStyle = "#0a0"
  context.lineWidth   = 0.02
  context.lineJoin    = "round"
  context.beginPath()
  for i in [1 ... size]
    context.moveTo(i, 0)
    context.lineTo(i, size)
    context.moveTo(0, i)
    context.lineTo(size, i)
  context.rect(0, 0, size, size)
  context.stroke()

  for i in [0 ... size]
    for j in [0 ... size]
      switch array[i][j]
        when 'x'
          context.beginPath()
          context.arc(i + 1/2, j + 1/2, 0.4, 0, 2 * Math.PI)
          context.fillStyle = "#000"
          context.fill()
          context.strokeStyle = "#000"
          context.stroke()
        when 'o'
          context.beginPath()
          context.arc(i + 1/2, j + 1/2, 0.4, 0, 2 * Math.PI)
          context.fillStyle = "#fff"
          context.fill()
          context.strokeStyle = "#000"
          context.stroke()

  return

writeMessage = (text) ->
  console.log(text)
  return

window.onclick = (event) ->
  i = Math.floor((event.clientX - offsetX) / scale)
  j = Math.floor((event.clientY - offsetY) / scale)
  if 0 <= i < size and 0 <= j < size
    socket.emit("click", i, j)
  return
