# logs server: it keeps in sync `logs` with peers
#
# Messages are stored as json files with name being their hash in
# hex

# Without any optimization, when two peers connect, they exchange the
# list of (hashes of) leaf logs they have and then, they ask for
# missing ones.

express = require 'express'
fs      = require 'fs'
path    = require 'path'
walker  = require 'walker'
agent   = require 'superagent'

conf    = require './conf'
logs    = require './logs'

app = express()

app.set 'view engine', 'jade'
app.set 'views', 'views'

app.get '/index', (req,res) ->
    res.render "page", {}

app.use express.static conf.logPath

app.listen conf.port

