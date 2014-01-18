express = require 'express'
assets = require('connect-assets')


# Helper to get path relative to the project root directory.
fromRoot = (requestedPath) ->
  require('path').join __dirname, '..', requestedPath

module.exports = app = express()

# View stuff.
app.engine 'jade', require('jade').__express
app.set 'view engine', 'jade'
app.set 'views', fromRoot 'views'

# Middleware
app.use express.logger('dev')
app.use app.router
app.use express.static fromRoot '/static'
app.use assets helperContext: app.locals, src: fromRoot 'assets'
app.use express.errorHandler()

# Routes.
app.get '/', (req, res) ->
  # Home route.
  res.render 'home'

