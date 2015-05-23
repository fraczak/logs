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
peers   = require 'peers'

conf    = require './conf'
logs    = require './logs'

app = express()

app.set 'view engine', 'jade'
app.set 'views', 'views'

# peer API

# asking for hashes
app.get '/index', (req,res) ->
    res.json logs.leaves req.query

# local API
app.get '/fetch', (req,res) ->
    host = req.query?.h? or peers.getHost()
    agent.get "#{host}/index"
    .end (err, res) ->
        if err
            console.log "Error fetching: #{err}"
            res.json err
        else
            logs.sync host, res
            res.json res
 


app.use express.static conf.logPath


app.listen conf.port

