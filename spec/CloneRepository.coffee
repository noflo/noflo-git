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
    dest.send null
    c.outPorts.out.detach out
    out = null
    c.outPorts.error.detach err
    err = null

  describe 'cloning a valid repository', ->
    it 'should succeed', (done) ->
      @timeout 20000
      mktemp.createDir 'noflo-git-' + Math.floor(Math.random() * (1<<24)), (err, repoPath) ->
        return done err if err

        out.on 'data', (data) ->
          chai.expect(data).to.equal repoPath
          fs.exists "#{repoPath}/package.json", (exists) ->
            chai.expect(exists).to.equal true
            done()
        dest.send repoPath
        ins.send 'git://github.com/bergie/create.git'
  describe 'cloning without destination', ->
    it 'should fail', (done) ->
      err.on 'data', (data) ->
        chai.expect(data).to.be.an 'error'
        done()
      ins.send 'git://github.com/bergie/create.git'
