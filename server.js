// Generated by CoffeeScript 1.9.1
(function() {
  var board, dirs, draw, fs, gameOver, hasToPass, http, idCounter, invertibles, io, player, port, put, reset, sendMessage, server, size, socketio, switchTurn, turn;

  http = require("http");

  fs = require("fs");

  socketio = require("socket.io");

  port = process.env.PORT || 5000;

  server = http.createServer(function(request, response) {
    switch (request.url) {
      case "/":
      case "/index.html":
        response.writeHead(200, {
          "Content-Type": "text/html"
        });
        response.write(fs.readFileSync("index.html"));
        break;
      case "/script.js":
        response.writeHead(200, {
          "Content-Type": "text/javascript"
        });
        response.write(fs.readFileSync("client.js"));
    }
    response.end();
  }).listen(port, function() {
    console.log("Listening on %d.", port);
  });

  io = socketio.listen(server);

  idCounter = 0;

  player = size = board = turn = null;

  setTimeout(function() {
    reset();
  });

  io.on("connection", function(socket) {
    socket.on("login", function(name) {
      var id;
      id = idCounter++;
      if (name === "") {
        name = "Anonymous" + String(id);
        socket.emit("set name", name);
      }
      draw();
      sendMessage("[ " + name + " log in ]");
      socket.on("disconnect", function() {
        sendMessage("[ " + name + " log out ]");
      });
      socket.on("click", function(x, y) {
        if ((turn != null) && player[turn] === id && (0 <= x && x < size) && (0 <= y && y < size)) {
          put(x, y);
        }
      });
      socket.on("entry", function() {
        if (player.black == null) {
          player.black = id;
          sendMessage("[ " + name + " play as black ]");
        } else if (player.white == null) {
          player.white = id;
          sendMessage("[ " + name + " play as white ]");
        }
      });
      socket.on("reset", function() {
        reset();
        draw();
        sendMessage("[ " + name + " reset ]");
      });
      socket.on("chat", function(text) {
        sendMessage(name + ": " + text);
      });
    });
  });

  sendMessage = function(text) {
    io.sockets.emit("message", text);
  };

  draw = function() {
    io.sockets.emit("draw", size, board);
  };

  reset = function() {
    var i, j, ref, ref1, x, y;
    player = {};
    size = 8;
    board = [];
    for (x = i = 0, ref = size; 0 <= ref ? i < ref : i > ref; x = 0 <= ref ? ++i : --i) {
      board[x] = [];
      for (y = j = 0, ref1 = size; 0 <= ref1 ? j < ref1 : j > ref1; y = 0 <= ref1 ? ++j : --j) {
        board[x][y] = "blank";
      }
    }
    board[3][3] = "black";
    board[3][4] = "white";
    board[4][3] = "white";
    board[4][4] = "black";
    turn = "black";
  };

  gameOver = function() {
    var blackCnt, i, j, ref, ref1, whiteCnt, x, y;
    turn = null;
    blackCnt = 0;
    whiteCnt = 0;
    for (x = i = 0, ref = size; 0 <= ref ? i < ref : i > ref; x = 0 <= ref ? ++i : --i) {
      for (y = j = 0, ref1 = size; 0 <= ref1 ? j < ref1 : j > ref1; y = 0 <= ref1 ? ++j : --j) {
        switch (board[x][y]) {
          case "black":
            blackCnt++;
            break;
          case "white":
            whiteCnt++;
        }
      }
    }
    sendMessage("[ black " + String(blackCnt) + "-" + String(whiteCnt) + " white ]");
  };

  switchTurn = function() {
    switch (turn) {
      case "black":
        turn = "white";
        break;
      case "white":
        turn = "black";
    }
  };

  put = function(x, y) {
    var i, invs, len, p;
    invs = invertibles(x, y);
    if (invs.length === 0) {
      return;
    }
    board[x][y] = turn;
    for (i = 0, len = invs.length; i < len; i++) {
      p = invs[i];
      board[p.x][p.y] = turn;
    }
    draw();
    sendMessage("[ " + turn + " " + String(x) + " " + String(y) + " ]");
    switchTurn();
    if (hasToPass()) {
      sendMessage("[ " + turn + " pass ]");
      switchTurn();
      if (hasToPass()) {
        sendMessage("[ " + turn + " pass ]");
        gameOver();
      }
    }
  };

  hasToPass = function() {
    var i, j, ref, ref1, x, y;
    for (x = i = 0, ref = size; 0 <= ref ? i < ref : i > ref; x = 0 <= ref ? ++i : --i) {
      for (y = j = 0, ref1 = size; 0 <= ref1 ? j < ref1 : j > ref1; y = 0 <= ref1 ? ++j : --j) {
        if (invertibles(x, y).length > 0) {
          return false;
        }
      }
    }
    return true;
  };

  invertibles = function(x, y) {
    var accum, d, i, len, temp, xx, yy;
    if (board[x][y] !== "blank") {
      return [];
    }
    accum = [];
    for (i = 0, len = dirs.length; i < len; i++) {
      d = dirs[i];
      temp = [];
      xx = x;
      yy = y;
      while (true) {
        xx += d.x;
        yy += d.y;
        if (!((0 <= xx && xx < size) && (0 <= yy && yy < size))) {
          break;
        } else if (board[xx][yy] === "blank") {
          break;
        } else if (board[xx][yy] === turn) {
          accum = accum.concat(temp);
          break;
        } else {
          temp.push({
            x: xx,
            y: yy
          });
        }
      }
    }
    return accum;
  };

  dirs = [
    {
      x: -1,
      y: -1
    }, {
      x: -1,
      y: 0
    }, {
      x: -1,
      y: +1
    }, {
      x: 0,
      y: -1
    }, {
      x: 0,
      y: +1
    }, {
      x: +1,
      y: -1
    }, {
      x: +1,
      y: 0
    }, {
      x: +1,
      y: +1
    }
  ];

}).call(this);
