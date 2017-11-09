noflo = require 'noflo'
chai = require 'chai'
mktemp = require 'mktemp'
path = require 'path'
fs = require 'fs'
baseDir = path.resolve __dirname, '../'

describe 'CloneRepository component', ->
  c = null
  ins = null
  dest = null
  out = null
  err = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'git/CloneRepository', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      dest = noflo.internalSocket.createSocket()
      c.inPorts.destination.attach dest
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
    err = noflo.internalSocket.createSocket()
    c.outPorts.error.attach err
  afterEach ->
    c.outPorts.out.detach out
    out = null
    c.outPorts.error.detach err
    err = null

  describe 'cloning a valid repository', ->
    it 'should succeed', (done) ->
      @timeout 20000
      mktemp.createDir 'noflo-git-' + Math.floor(Math.random() * (1<<24)), (error, repoPath) ->
        return done error if error

        out.on 'data', (data) ->
          chai.expect(data).to.equal repoPath
          fs.exists "#{repoPath}/package.json", (exists) ->
            chai.expect(exists).to.equal true
            done()
        err.on 'data', done
        dest.send repoPath
        ins.send 'https://github.com/noflo/noflo-git.git'
