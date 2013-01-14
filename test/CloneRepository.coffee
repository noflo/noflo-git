component = require "../components/CloneRepository"
socket = require('noflo').internalSocket
fs = require 'fs'


setupComponent = ->
  c = component.getComponent()
  ins = socket.createSocket()
  dest = socket.createSocket()
  out = socket.createSocket()
  err = socket.createSocket()
  c.inPorts.in.attach ins
  c.inPorts.destination.attach dest
  c.outPorts.out.attach out
  c.outPorts.error.attach err
  [c, ins, dest, out, err]

exports['test cloning a valid repository'] = (test) ->
  [c, ins, dest, out, err] = setupComponent()
  path = '/tmp/noflo-git-' + Math.floor(Math.random() * (1<<24))
  fs.mkdirSync path

  out.once 'data', (data) ->
    test.equal data, path
    fs.exists "#{path}/create/package.json", (exists) ->
      test.ok exists
      test.done()

  dest.send path
  ins.send 'git://github.com/bergie/create.git'

exports['test cloning without destination'] = (test) ->
  [c, ins, dest, out, err] = setupComponent()

  err.once 'data', (data) ->
    test.ok data, 'Errors are objects'
    test.ok data.message, 'There needs to be an error message'
    test.equal data.message, 'no destination directory specified'

    test.done()

  ins.send 'git://github.com/bergie/create.git'
