crypto = require 'crypto'

conf   = require './conf'

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

module.exports =
    verifySign : verifySign
    sign       : sign
    hash       : hash
