component = require "../components/CloneRepository"
socket = require('noflo').internalSocket
fs = require 'fs'
mktemp = require 'mktemp'

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
  mktemp.createDir 'noflo-git-' + Math.floor(Math.random() * (1<<24)), (err, repoPath) ->
    if err
      test.ok false, 'Failed to create temp dir'
      test.done()
      return

    out.once 'data', (data) ->
      test.equal data, repoPath
      fs.exists "#{repoPath}/package.json", (exists) ->
        test.ok exists
        test.done()

    dest.send repoPath
    ins.send 'git://github.com/bergie/create.git'

exports['test cloning without destination'] = (test) ->
  [c, ins, dest, out, err] = setupComponent()

  err.once 'data', (data) ->
    test.ok data, 'Errors are objects'
    test.ok data.message, 'There needs to be an error message'
    test.equal data.message, 'no destination directory specified'

    test.done()

  ins.send 'git://github.com/bergie/create.git'
