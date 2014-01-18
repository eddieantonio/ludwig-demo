http = require 'http'
express = require 'express'
#redis = require 'redis'

app = express()

# SocketIO stuff.
module.exports = server = http.createServer app
io = require('socket.io').listen server

# View stuff.
app.engine 'jade', require('jade').__express
app.set 'view engine', 'jade'
app.set 'views', __dirname + '/views'

# Middleware
app.use express.logger('dev')
app.use app.router
app.use express.static(__dirname + '/static')
app.use express.errorHandler()

# Routes.
app.get '/', (req, res) ->
  # Home route.
  res.render 'home'

app.get '/sockets', (req, res) ->
  res.send 'I dunno lol.'


io.sockets.on 'connection', (socket) ->
  # Here would be Redis stuff.
  socket.emit 'messages',
    id: '12345'
    payload: 'hi'

  socket.on 'new tuple', (data) ->
    console.log 'I dunno what to do with all these data'

