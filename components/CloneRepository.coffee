noflo = require 'noflo'
gitgo = require 'gitgo'
path = require 'path'

ignores = [
  'You appear to have cloned an empty repository'
]

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'in',
    datatype: 'string'
    description: 'Repository URL'
  c.inPorts.add 'destination',
    datatype: 'string'
    description: 'Repository directory path'
  c.outPorts.add 'out',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'in', 'destination'
    [repo, destination] = input.getData 'in', 'destination'
    console.log repo, destination

    rootDir = path.dirname destination
    repoDir = path.basename destination
    request = gitgo rootDir, [
      'clone'
      repo
      repoDir
    ]
    errors = []
    request.on 'error', (err) ->
      for ignore in ignores
        return if err.message.indexOf(ignore) isnt -1
      errors.push err
    request.on 'data', (data) ->
    request.on 'end', ->
      if errors.length
        output.done errors[0]
        return
      output.sendDone destination
