noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-gestures'

describe 'DetectTarget component', ->
  c = null
  ins = null
  target = null
  pass = null
  fail = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'gestures/DetectTarget', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      target = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      c.inPorts.target.attach target
      done()
  beforeEach ->
    pass = noflo.internalSocket.createSocket()
    fail = noflo.internalSocket.createSocket()
    c.outPorts.pass.attach pass
    c.outPorts.fail.attach fail
  afterEach ->
    c.outPorts.pass.detach pass
    c.outPorts.fail.detach fail

  describe 'checking event with the right target', ->
    it 'should pass', (done) ->
      expected =
        1:
          start:
            foo: 'bar'
      pass.once 'data', (data) ->
        chai.expect(data).to.eql expected
        done()
      target.send 'foo=bar'
      ins.send expected

  describe 'checking event with a wrong target', ->
    it 'should fail', (done) ->
      expected =
        1:
          start:
            foo: 'bar'
      pass.once 'data', (data) ->
        chai.expect(data).to.eql expected
        done()

      target.send 'foo=baz'
      ins.send expected

  describe 'checking multitouch event with the right target', ->
    it 'should pass', (done) ->
      expected =
        2:
          start:
            foo: 'bar'
        3:
          start:
            foo: 'bar'
      pass.once 'data', (data) ->
        chai.expect(data).to.eql expected
        done()
      target.send 'foo=bar'
      ins.send expected

  describe 'checking event with a wrong target', ->
    it 'should fail', (done) ->
      expected =
        2:
          start:
            foo: 'baz'
        3:
          start:
            foo: 'bar'
      pass.once 'data', (data) ->
        chai.expect(data).to.eql expected
        done()

      target.send 'foo=baz'
      ins.send expected
