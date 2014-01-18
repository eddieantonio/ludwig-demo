http = require 'http'

PORT = process.env.PORT or 3000

# Create an HTTP server from the Express app.
server = http.createServer require('./app')
# Configure SocketIO to work with it.
require('./server') server

server.listen PORT, ->
  console.log("Listening on #{PORT}")

