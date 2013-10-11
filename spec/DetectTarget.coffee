noflo = require 'noflo'
if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  DetectTarget = require '../components/DetectTarget.coffee'
else
  DetectTarget = require 'noflo-gestures/components/DetectTarget.js'

describe 'DetectTarget component', ->
  c = null
  ins = null
  target = null
  pass = null
  fail = null
  beforeEach ->
    c = DetectTarget.getComponent()
    ins = noflo.internalSocket.createSocket()
    target = noflo.internalSocket.createSocket()
    pass = noflo.internalSocket.createSocket()
    fail = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.inPorts.target.attach target
    c.outPorts.pass.attach pass
    c.outPorts.fail.attach fail

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
