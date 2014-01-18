# SocketIO stuff.
# Pass the server into this file

#redis = require 'redis'
socketio = require('socket.io')

module.exports = (server) ->
  io = socketio.listen server

  io.sockets.on 'connection', (socket) ->
    # Here would be Redis stuff.
    socket.emit 'messages',
      id: '12345'
      payload: 'hi'

    socket.on 'new tuple', (data) ->
      console.log 'I dunno what to do with all these data'

