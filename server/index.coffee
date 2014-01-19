# SocketIO stuff.
# Export is a function that you call with an HTTP server
# and get back a shiny socket.io server.

redis = require 'redis'
socketio = require('socket.io')

CHANNEL = 'ludwig_demo'
# Helper: makes... I guess, namespaced keys in Redis.
keyFor = (keys...) ->
  CHANNEL + ':' + keys.join(':')


# Parses the result message from Redis (presumably).
# The resultant object will have an ID and a content hash.
parseMessage = (message) ->
  match = message.match /(\d+):((?:.|\n)*)/
  console.assert(match isnt null)

  # Note that the client is to supply 'tatime' and 'rid'.
  id: parseInt match[1], 10
  content:
    # Note: I just kind of hard-coded this....
    nlptext: match[2]


# Connects to Redis, and forwards and processes messages between the client.
# Note: uses one Redis per connection, because I'm lazy. :/
prettyMuchJustForwardRedis = (socket) ->
  subscriber = redis.createClient()
  publisher = redis.createClient()

  # Maps 'internal IDs' to 'request IDs'
  activeRequests = {}

  # Subscribe to the "results" channel.
  subscriber.subscribe keyFor 'results'

  # When subscribed... uh.. ummmm...?
  subscriber.on 'subscribe', (channel, _count) ->

  # On message receive, forward it to Redis.
  socket.on 'message', (message) ->
    publisher.incr keyFor('id'), (err, id) ->
      # Publish the ID and message.
      publisher.publish keyFor('inbox'), "#{id}:#{message.text}"
      # Store any metadata in the active requests.
      activeRequests[id] = message.info

  # Then parse and forward the message from Redis:
  subscriber.on 'message', (channel, message) ->
    console.assert(channel is keyFor 'results')

    # Parse the message...
    result = parseMessage message
    id = result.id
    # Extract that metadata and set it as the 'RID'.
    result.rid = activeRequests[id]

    socket.emit 'result', result
    # We can stop tracking the request now.
    delete activeRequests[id]

  # Make sure on client disconnect to disconnect from **both** Redis clients!
  socket.on 'disconnect', ->
    subscriber.unsubscribe keyFor 'results'
    subscriber.quit()
    publisher.quit()


module.exports = (server) ->
  io = socketio.listen server
  io.sockets.on 'connection', prettyMuchJustForwardRedis

