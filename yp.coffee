ld   = require "lodash"
conf = require "./conf"
jfo  = require "json-file-object"


data = ld.indexBy [{pubKeyStr:conf.pubKeyStr, name:"Me"}], 'pubKeyStr'
data = jfo
    value : data
    file  : "yp.json"

_data = ld.transform data, (res, val) ->
    res[val.name] = val

del = (pubKeyStr) ->
    record = data[pubKeyStr]
    return null unless record
    delete data[pubKeyStr]
    delete _data[record.name]
    return true

module.exports =
    list   : ->
        ld.transform data, (res, val) ->
            res.push val
        , []
    getPem : (name) ->
        conf.strToPem _data[name].pubKeyStr
    get: (pubKeyStr) ->
        data[pubKeyStr]
    add    : (record) ->
        return null unless record.name and record.pubKeyStr
        return null if data[record.pubKeyStr] or _data[record.name]
        data[record.pubKeyStr] = record
        _data[record.name] = record
        return true
    delName : (val) ->
        return null unless _data[val]
        return del _data[val]
    del : del

