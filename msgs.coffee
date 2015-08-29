crypto  = require 'crypto'
openpgp = require 'openpgp'
async   = require 'async'
conf    = require './conf'
logs    = require './logs'

encrypt = (pubKey, msg, cb = (err, encryptedMsg) ->) ->
    key = conf.strToPem pubKey
    publicKey = openpgp.key.readArmored key
    openpgp.encryptMessage(publicKey.keys, msg)
    .then (m) ->
        cb null, m
    .catch cb

decrypt = (privKey, msg, cb = (err, decryptedMsg) -> ) ->
    privateKey = openpgp.key.readArmored(conf.strToPem privKey).keys[0]
    pgpMessage = openpgp.message.readArmored msg
    openpgp.decryptMessag privateKey, pgpMessage
    .then (m) ->
        cb null, m
    .catch (e) ->
        cb e

add = (pubKey, msg, cb) ->
    encrypt pubKey, msg, (err, m) ->
        logs.add (JSON.stringify {to:pubKey, msg:encryptedMsg}), cb

get = (msgHash, cb) ->
    logs.get msgHash, (err, log) ->
        if err
            return cb err
        try
            {to, msg} = JSON.parse log.data
            decrypt conf.privKeyPem, msg.data, (err,decryptedMsg) ->
                return cb err if err
                cb {author: to, msg: decryptedMsg}
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
