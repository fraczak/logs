crypto  = require 'crypto'
walker  = require 'walker'
fs      = require 'fs'
ld      = require 'lodash'
agent   = require 'superagent'
path    = require 'path'

conf    = require './conf'

_root   = null
_leaves = null
_logs   = {}
_parents = {}

_processing = {}

do ->
    walker conf.logPath
    .on 'file', (file) ->
        log = JSON.parse fs.readFileSync file
        logHash = path.basename file
        _logs[logHash] = true
        if log.parent and log.parent isnt ""
            _parents[log.parent] = true
        else
            _root = logHash
    .on 'end', ->
        _leaves = ld.transform _logs, (res, val, key) ->
            res[key] = true if not _parents[key]

verifySign = ({parent,data,author,sign}) ->
    try
        v = crypto.createVerify 'RSA-SHA256'
        for part in [parent,data]
            v.update part
        return v.verify author, sign, 'hex'
    catch e
        console.error "Error: #{e}"
        return false
verifySign["in"] =
    parent:"HexSha256String"
    data:"String"
    author: "PemPublicKeyString"
    sign: "HexSignString"
verifySign["out"] = "Boolean"

sign = ({parent, data}) ->
    parent = parent or ""
    data   = data or ""
    s = crypto.createSign 'RSA-SHA256'
    for part in [parent,data]
        s.update part
    parent: parent
    data  : data
    author: conf.pubKey
    sign  : s.sign conf.privKey, 'hex'
sign["in"] =
    parent:"HexSha256String"
    data:"String"
sign["out"] =
    parent:"HexSha256String"
    data:"String"
    author: "PemPublicKeyString"
    sign: "HexSignString"

hash = ({parent,data,author,sign}) ->
    console.log "HASH: #{parent}, #{data}, #{author}, #{sign}"
    h = crypto.createHash 'SHA256'
    for part in [parent,data,author,sign]
        h.update part
    h.digest 'hex'
hash["in"] =
    parent:"HexSha256String"
    data:"String"
    author: "PemPublicKeyString"
    sign: "HexSignString"
hash["out"] = "HexSha256String"

leaves = (query) ->
    # query could be a map {author: [...], parent_author: [...]}
    ld.map _leaves, (val, key) ->
        key

_add = ({logHash,log}) ->
    deps = _processing[logHash] or {}
    delete _processing[logHash]
    fs.writeFile path.join(conf.logPath,logHash), JSON.stringify(log), (err) ->
        if not err
            _logs[logHash] = true
            _leaves[logHash] = true
            delete _leaves[log.parent]
            ld.forEach deps, (log,logHash) ->
                _add {logHash,log}

_cancel = (logHash) ->
    deps = _processing[logHash] or {}
    delete _processing[logHash]
    ld.forEach deps, (log,logHash) ->
        _cancel logHash

_fetch = (host, logHash, children = {}) ->
    return if _processing[logHash] or _logs[logHash]
    _processing[logHash] = children
    console.log "GET: #{host}/#{logHash}"
    agent.get "#{host}/#{logHash}"
    .end (err, data) ->
        if err
            console.log "Problem: #{err}"
            _cancel logHash
        else
            console.log "DATA: ", data
            log = JSON.parse data.text
            if (logHash is hash log) and (verifySign log)
                if _logs[log.parent]
                    _add {logHash, log}
                else if _processing[log.parent]
                    _processing[log.parent][logHash] = log
                else
                    o = {}
                    o[logHash] = log
                    _fetch host, log.parent, o
            else
                console.log "Fake log? : #{logHash}"
                _cancel logHash

sync = (host, leaves) ->
    ld.forEach leaves, (log) ->
        _fetch host, log, {}

module.exports =
    verifySign : verifySign
    sign       : sign
    hash       : hash
    leaves     : leaves
    sync       : sync
