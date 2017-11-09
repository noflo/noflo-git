noflo = require 'noflo'
gitgo = require 'gitgo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'in',
    datatype: 'string'
    description: 'Commit message'
  c.inPorts.add 'repo',
    datatype: 'string'
    description: 'Repository directory path'
  c.outPorts.add 'out',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'in', 'repo'
    [message, repo] = input.getData 'in', 'repo'
    request = gitgo repo, [
      'commit'
      '-m'
      message
    ]
    errors = []
    request.on 'error', (err) ->
      errors.push err
    request.on 'data', (data) ->
    request.on 'end', ->
      if errors.length
        output.done errors[0]
        return
      output.sendDone message
