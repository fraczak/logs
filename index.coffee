# logs server: it keeps in sync `logs` with peers
#
# Messages are stored as json files with name being their hash in
# hex

# Without any optimization, when two peers connect, they exchange the
# list of (hashes of) logs they have and then, they ask for
# missing ones.

express = require 'express'
fs      = require 'fs'
path    = require 'path'
walker  = require 'walker'
agent   = require 'superagent'
bodyParser = require 'body-parser'

peers   = require './peers'
conf    = require './conf'
logs    = require './logs'
msgs    = require './msgs'
yp      = require './yp'

app   = express()
local = express()

app.set 'view engine', 'jade'
app.set 'views', 'views'
app.use bodyParser.json()
app.use bodyParser.urlencoded { extended: true }


# asking for hashes
app.get '/logs', (req,res) ->
    # req.query
    logs.find null, (data) ->
        res.json data

app.get '/logs/:hash', (req, res) ->
    logs.get req.params.hash, (err, data) ->
        if err
            res.status(400).json err
        res.json data

#### local APIs
app.use "/#{conf.secret}", local

app.use express.static "public"

#  trigger sync with a peer
local.get "/sync", (req,res) ->
    host = req.query?.h or peers.getHost()
    agent.get "#{host}/index"
    .end (err, data) ->
        if err
            console.log "Error fetching: #{err}"
            res.json err
        else
            data = JSON.parse data.text
            logs.sync host, data
            res.json data

#  post a local message
local.post "/post", (req,res) ->
    to = conf.pemToStr req.body.to
    msg = req.body.msg
    msgs.add to, msg, (err, logHash) ->
        return res.json logHash unless err
        res.status(400).json err

# get message by its `hash`
local.get "/get/:hash", (req,res) ->
    msgs.get req.params.hash, (err, data) ->
        if err
            res.status(400).json err
        res.json data

###################################
#  web interfaces to `msgs` messages
local.get "/compose", (req,res) ->
    res.render "compose", { to:req.query?.to, yp }
local.get "/browse", (req,res) ->
    msgs.getAllToMe (err, messages) ->
        console.log messages
        res.render "browse", { messages, yp}
local.get "/read/:hash", (req,res) ->
    msgs.get req.params.hash, (err, data) ->
        if err
            res.status(400).json err
        res.render "read", data
local.get "/yp", (req,res) ->
    res.render "yp", { yp }

local.get "/", (req,res) ->
    res.render "client"

port = conf.port
if (p = process.argv[2])
    p = parseInt p
    if ( p > 1024 and p < 65536 )
        port = p


app.listen port, ->
    console.log "http://localhost:#{port}/#{conf.secret}/"
