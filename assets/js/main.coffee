# Home page stuff.
# Requires
#  - $ (jQuery or Zepto)
#  - socket.io


# SocketIO stuff.
startSocketIO = (onResult) ->
  # Get the address from the browser.
  address = window.location.origin

  socket = io.connect address

  # Call 'onResult' when a result is returned.
  socket.on 'result', (data) ->
    console.log 'Received result:', data
    onResult(null, data)

  # Returns the "message" callback.
  (data, cb) ->
    console.log 'submit that', data
    socket.emit 'message', data
    cb(null, data) if cb?



# Adding results to the DOM.
makeResult = (result) ->
  $template = $($('#t-result').html())

  # All of the metadata.
  $template.find('.request-id').text(result.rid)
  $template.find('.internal-id').text(result.id)
  $template.find('.tatime').text("#{result.tatime} ms")

  mainContent = Object.keys(result.content)[0]
  
  $template.find('.content')
    .addClass(mainContent)
    .text(result.content[mainContent])
 
  $template

addResult = ($resultBox, result) ->
  $result = makeResult result
  $resultBox.children('.placeholder').addClass('hide')
  $result.prependTo $resultBox

# Binds the textarea for events and stuff.
bindEntry = ($input, onSubmit) ->
  $input.bind 'keypress', (evt) ->
    # When enter is pressed without shift, submit the text.
    if evt.keyCode is 13 and not evt.shiftKey
      # Don't allow the newline to sneak in.
      evt.preventDefault()

      text = $input.val()
      $input.text()
      onSubmit text if onSubmit?

$ ->
  $resultBox = $ '#results'

  # Start SocketIO and get bind the "add result" event on message receipt.
  submitMessage = startSocketIO (err, data) ->
    addResult $resultBox, data
  # Bind the input entry and make sure to submit message with SocketIO.
  bindEntry $('#main-input > textarea'), (text) ->
    submitMessage text

