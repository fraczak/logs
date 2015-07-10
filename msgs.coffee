crypto  = require 'crypto'
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

module.exports = { add, get }
