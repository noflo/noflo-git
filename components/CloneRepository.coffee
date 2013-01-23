noflo = require 'noflo'
gitgo = require 'gitgo'
path = require 'path'

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

    rootDir = path.dirname @destination
    repoDir = path.basename @destination
    request = gitgo rootDir, [
      'clone'
      repo
      repoDir
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
