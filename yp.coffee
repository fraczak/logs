ld   = require "lodash"
conf = require "./conf"

_data = [{name: "Wojtek", pubKeyStr: conf.pubKeyStr}]
_data_idx = ld.indexBy _data, "name"
_data_rev_idx = ld.indexBy _data, "pubKeyStr"
all = ->
    _data

module.exports = {
    all
    getPem : (name) ->
        conf.strToPem _data_idx[name].pubKeyStr
    getName: (pubKeyStr) ->
        _data_rev_idx[pubKeyStr]?.name or pubKeyStr
}
