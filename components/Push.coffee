noflo = require 'noflo'
gitgo = require 'gitgo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'repo',
    datatype: 'string'
    description: 'Repository directory path'
  c.inPorts.add 'remote',
    datatype: 'string'
    description: 'Repository URL'
  c.inPorts.add 'local',
    datatype: 'string'
    description: 'Branch name'
  c.outPorts.add 'out',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'
  c.forwardBrackets =
    repo: ['out', 'error']
  c.process (input, output) ->
    return unless input.hasData 'repo', 'remote', 'local'
    [repo, remote, branch] = input.getData 'repo', 'remote', 'local'
    request = gitgo repo, [
      'push'
      remote
      branch
    ]
    errors = []
    request.on 'error', (err) ->
      errors.push err
    request.on 'data', (data) ->
    request.on 'end', ->
      if errors.length
        output.done errors[0]
        return
      output.sendDone repo
