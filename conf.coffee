path = require 'path'
fs   = require 'fs'

module.exports =
    logPath : path.join 'public', 'logs'
    pubKey  : fs.readFileSync path.join('private', 'pub.pem'), 'ascii'
    privKey : fs.readFileSync path.join('private', 'priv.pem'), 'ascii'
    port    : 3333
