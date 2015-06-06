path = require 'path'
fs   = require 'fs'

module.exports =
    logPath : path.join 'public', 'logs'
    pubKey  : fs.readFileSync path.join('private', 'pub.pem'), 'ascii'
    privKey : fs.readFileSync path.join('private', 'priv.pem'), 'ascii'
    secret  :
        fs.readFileSync path.join('private', 'secret.txt'), 'ascii'
        .split('\n')[0]
    port    : 3333
