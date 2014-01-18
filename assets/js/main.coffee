# Home page stuff.
# Requires
#  - $ (jQuery or Zepto)
#  - socket.io
$ ->
  address = window.location.origin
  socket = io.connect address
  socket.on 'messages', (data) ->
    console.log 'There are my datums:'
    console.log data
    socket.emit 'new tuple', 'herp derp'

