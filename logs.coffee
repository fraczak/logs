crypto  = require 'crypto'
walker  = require 'walker'
fs      = require 'fs'
ld      = require 'lodash'
agent   = require 'superagent'
path    = require 'path'

conf    = require './conf'

_leaves = null
_logs = {}
_parents = {}
_processing = {}

do ->
    walker conf.logPath
    .on 'file', (file) ->
        _logs[file] = true
        {parent,author} = log = fs.readFileSync file
        _parents[parent] = true
    .on 'end', ->
        _leaves = ld.transform _logs, (res, val, key) ->
            res[key] = true if not _parents[key]

verifySign = ({parent,data,author,sign}) ->
    v = crypto.createVerify 'RSA-SHA256'
    for part in [parent,data]
        v.update part
    v.verify author, sign, 'hex'
verifySign["in"] =
    parent:"HexSha256String"
    data:"String"
    author: "PemPublicKeyString"
    sign: "HexSignString"
verifySign["out"] = "Boolean"

sign = ({parent, data}) ->
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
    _leaves

_add = ({logHash,log}) ->
    deps = _processing[logHash] or {}
    delete _processing[logHash]
    fs.writeFile path.join(config.logPath,logHash), log, (err) ->
        if not err
            ld.forEach deps, (log,logHash) ->
                _add {logHash,log}

_fetch = (host, logHash, dep = {}) ->
    return if _processing[logHash] or _logs[logHash]
    _processing[logHash] = dep
    agent.get "#{host}/logs/#{logHash}"
    .end (err, log) ->
        if err
            console.log "Problem: #{err}"
            delete _processing[logHash]
        else
            if (logHash is hash log) and (verifySign log)
                {parent} = log
                if _logs[parent]
                    _add {logHash, log}
                else if _processing[parent]
                    _processing[logHash][logHash] = log
                    _processing[parent] =
                        ld.assing _processing[parent], _processing[logHash]
                else
                    _processing[logHash][logHash] = log
                    _fetch host, parent, _processing[logHash]
            else
                console.log "Fake log? : #{logHash}"
                delete _processing[logHash]

sync = (host, leaves) ->
    ld.forEach leaves, (log) ->
        _fetch host, log, {}

module.exports =
    verifySign : verifySign
    sign       : sign
    hash       : hash
    leaves     : leaves
    sync       : sync
