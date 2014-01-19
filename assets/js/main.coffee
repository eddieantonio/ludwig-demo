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
    socket.emit 'message', data
    cb(null, data) if cb?


# Generates monotonic IDs.
newID = do ->
  id = 0
  ->
    id += 1
    return id


# Parses NLPText output.
parseContent = (text) ->
  headerPattern = /^D\tfile=\tid=\ttitle=\tdate=\turl=\n/
  # The pattern may match at the start and will be removed.
  text.replace(headerPattern, '')


# Adding results to the DOM.
makeResult = (result) ->
  $template = $($('#t-result').html())

  # All of the metadata.
  $template.find('.request-id').text(result.rid)
  $template.find('.internal-id').text(result.id)
  $template.find('.tatime').text("#{result.tatime} ms")

  mainContent = Object.keys(result.content)[0]

  # Does some post-processing on the return... in case that's necessary.
  content = parseContent result.content[mainContent]
  
  $template.find('.content')
    .addClass(mainContent)
    .text(content)
 
  $template

addResult = ($resultBox, result) ->
  $result = makeResult result
  $resultBox.children('.placeholder').remove()
  $result.prependTo $resultBox

# Binds the textarea for events and stuff.
bindEntry = ($input, onSubmit) ->
  $input.bind 'keypress', (evt) ->
    # When enter is pressed without shift, submit the text.
    if evt.keyCode is 13 and not evt.shiftKey
      # Don't allow the newline from pressing 'enter' to sneak in.
      evt.preventDefault()

      text = $input.val()
      $input.text()
      onSubmit text if onSubmit?

      # Reset the input:
      $input.val('')

$ ->
  $resultBox = $ '#results'

  requests = {}

  # Start SocketIO and get bind the "add result" event on message receipt.
  submitMessage = startSocketIO (err, data) ->
    rid = data.rid

    # Only calculate turnaround time if a request ID was returned.
    if rid?
      # Append the turnaround time before rendering...
      timeTaken = performance.now() - requests[rid].started
      data.tatime = timeTaken.toFixed 1
    else
      data.tatime = data.rid = 'Unknown'

    addResult $resultBox, data

  # Bind the input entry and make sure to submit message with SocketIO.
  bindEntry $('#main-input > textarea'), (text) ->

    # Create a unique ID. 
    rid = newID()
    # Keep some metadata for the request.
    requests[rid] =
      message: text
      started: performance.now()
      rid: rid

    submitMessage text: text, info: rid

