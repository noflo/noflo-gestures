noflo = require 'noflo'
if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  DegreesToCardinal = require '../components/DegreesToCardinal.coffee'
else
  DegreesToCardinal = require 'noflo-gestures/components/DegreesToCardinal.js'

describe 'DegreesToCardinal component', ->
  c = null
  degrees = null
  heading = null
  beforeEach ->
    c = DegreesToCardinal.getComponent()
    degrees = noflo.internalSocket.createSocket()
    heading = noflo.internalSocket.createSocket()
    c.inPorts.degrees.attach degrees
    c.outPorts.heading.attach heading

  describe 'calculating compass headings', ->
    it 'should return E for 90', (done) ->
      heading.once 'data', (data) ->
        chai.expect(data).to.equal 'E'
        done()
      degrees.send 90
    it 'should return N for 315', (done) ->
      heading.once 'data', (data) ->
        chai.expect(data).to.equal 'N'
        done()
      degrees.send 315
    it 'should return W for 226', (done) ->
      heading.once 'data', (data) ->
        chai.expect(data).to.equal 'W'
        done()
      degrees.send 226
