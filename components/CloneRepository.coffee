noflo = require 'noflo'
gitgo = require 'gitgo'

class CloneRepository extends noflo.AsyncComponent
  constructor: ->
    @destination = null

    @inPorts =
      in: new noflo.Port
      destination: new noflo.Port
    @outPorts =
      out: new noflo.Port
      error: new noflo.Port

    @inPorts.destination.on 'data', (data) =>
      @destination = data

    super()

  doAsync: (repo, callback) ->
    unless @destination
      callback new Error 'no destination directory specified'
      return

    request = gitgo @destination, [
      'clone'
      repo
    ]

    request.on 'end', =>
      @outPorts.out.beginGroup repo
      @outPorts.out.send @destination
      @outPorts.out.endGroup()
      @outPorts.out.disconnect()
      callback()
    request.on 'error', (err) =>
      @outPorts.out.disconnect()
      callback err
    @outPorts.out.connect()

exports.getComponent = -> new CloneRepository
