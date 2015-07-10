conf = require "./conf"

_data = {name: "Wojtek", addr: conf.pubKey}
all = ->
    _data

module.exports = { all }
