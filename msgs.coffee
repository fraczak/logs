crypto  = require 'crypto'
async   = require 'async'
conf    = require './conf'
logs    = require './logs'

add = (pubKey, msg, cb) ->
    encryptedMsg = crypto.publicEncrypt conf.strToPem(pubKey), new Buffer msg
    logs.add (JSON.stringify {to:pubKey, msg:encryptedMsg}), cb

get = (msgHash, cb) ->
    logs.get msgHash, (err, log) ->
        if err
            return cb err
        try
            {to, msg} = JSON.parse log.data
            decryptedMsg = crypto.privateDecrypt conf.privKeyPem,
                new Buffer msg.data
            cb err,
                author: to,
                msg: decryptedMsg.toString()
        catch e
            cb e, log

getAllToMe = (cb) ->
    logs.find (log) ->
        try
            msg = JSON.parse log.data
            return true if msg.to is conf.pubKeyStr
        catch e
            console.log e
        return false
    , (hashes) ->
        async.map hashes, get, cb

module.exports = { add, get, getAllToMe }
