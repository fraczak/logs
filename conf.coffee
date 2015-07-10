path = require 'path'
fs   = require 'fs'

pemToStr = (pem) ->
    lines = pem.split /\r\n|\n/
    res = []
    i = 0
    while 0 isnt lines[i].indexOf "-----BEGIN"
        i++
    i++
    while 0 isnt lines[i].indexOf "-----END"
        res.push lines[i]
        i++
    res.join("")

strToPem = (str, header="PUBLIC KEY") ->
    lines = ["-----BEGIN #{header}-----"];
    pos = 0
    while pos < str.length
        lines.push str.substr pos, 64
        pos += 64
    lines.push "-----END #{header}-----"
    lines.push ""
    lines.join "\n"

module.exports =
    logPath : path.join 'public', 'logs'
    pubKeyStr: pemToStr fs.readFileSync path.join('private', 'pub.pem'), 'ascii'
    privKeyPem: fs.readFileSync path.join('private', 'priv.pem'), 'ascii'
    secret  :
        fs.readFileSync path.join('private', 'secret.txt'), 'ascii'
        .split('\n')[0]
    port    : 3333
    pemToStr: pemToStr
    strToPem: strToPem
