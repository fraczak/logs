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

app   = express()
local = express()

app.set 'view engine', 'jade'
app.set 'views', 'views'
app.use bodyParser.json()
app.use bodyParser.urlencoded { extended: true }


# asking for hashes
app.get '/index', (req,res) ->
    res.json logs.find req.query

app.get /^[/]([a-f0-9]{64})$/, (req, res) ->
    logHash = req.params[0]
    fs.readFile path.join(conf.logPath,logHash), (err, data) ->
        res.json JSON.parse data unless err

#### local APIs
app.use "/#{conf.secret}", local

#  trigger sync with a peer 
local.get "/sync", (req,res) ->
    host = req.query?.h? or peers.getHost()
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
    data = req.body.data
    logs.add data, (err, logHash) ->
        return res.json logHash unless err
        res.status(400).json err

#  a web interface to compose a message
local.get "/compose", (req,res) ->
    res.render "compose"

port = conf.port
if (p = process.argv[2])
    p = parseInt p
    if ( p > 1024 and p < 65536 )
        port = p

app.listen port, ->
    console.log "http://localhost:#{port}/#{conf.secret}/compose"

