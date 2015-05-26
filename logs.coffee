crypto  = require 'crypto'
walker  = require 'walker'
fs      = require 'fs'
ld      = require 'lodash'
agent   = require 'superagent'
path    = require 'path'

conf    = require './conf'

_logs       = {}
_ready      = false
_processing = {}

do ->
    walker conf.logPath
    .on 'file', (file) ->
        log = JSON.parse fs.readFileSync file
        logHash = path.basename file
        _logs[logHash] = true
    .on 'end', ->
        _ready = true

verifySign = ({data,author,sign}) ->
    try
        v = crypto.createVerify 'RSA-SHA256'
        v.update data
        return v.verify author, sign, 'hex'
    catch e
        console.error "Error: #{e}"
        return false
verifySign["in"] =
    data:"String"
    author: "PemPublicKeyString"
    sign: "HexSignString"
verifySign["out"] = "Boolean"

sign = (data) ->
    s = crypto.createSign 'RSA-SHA256'
    s.update data
    data  : data
    author: conf.pubKey
    sign  : s.sign conf.privKey, 'hex'
sign["in"] =
    "String"
sign["out"] =
    data:"String"
    author: "PemPublicKeyString"
    sign: "HexSignString"

hash = ({data,author,sign}) ->
    console.log "HASH: #{data}, #{author}, #{sign}"
    h = crypto.createHash 'SHA256'
    for part in [data,author,sign]
        h.update part
    h.digest 'hex'
hash["in"] =
    data:"String"
    author: "PemPublicKeyString"
    sign: "HexSignString"
hash["out"] = "HexSha256String"

find = (query) ->
    # query could be a map {author: [...], etc...}
    ld.map _logs, (val, key) ->
        key

add = (data, cb) ->
    m = sign data
    logHash = hash m
    _processing[logHash] = true
    fs.writeFile path.join(conf.logPath,logHash), JSON.stringify(m), (err) ->
        if not err
            _logs[logHash] = true
            cb null, logHash
        else
            cb err
        delete _processing[logHash]

_fetch = (host, logHash) ->
    return if _processing[logHash] or _logs[logHash]
    _processing[logHash] = true
    console.log "GET: #{host}/#{logHash}"
    agent.get "#{host}/#{logHash}"
    .end (err, data) ->
        if err
            console.log "Problem: #{err}"
            delete _processing[logHash]
        else
            console.log "DATA: ", data
            log = JSON.parse data.text
            if (logHash is hash log) and (verifySign log)
                fs.writeFile path.join(conf.logPath,logHash), JSON.stringify(log), (err) ->
                    if not err
                        _logs[logHash] = true
                    delete _processing[logHash]
            else
                console.log "Fake log? : #{logHash}"
                delete _processing[logHash]

sync = (host, logs) ->
    ld.forEach logs, (logHash) ->
        _fetch host, logHash

module.exports = { verifySign, hash, find, sync, add }
