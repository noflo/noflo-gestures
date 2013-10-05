noflo = require 'noflo'
if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  DegreesToCompass = require '../components/DegreesToCompass.coffee'
else
  DegreesToCompass = require 'noflo-gestures/components/DegreesToCompass.js'

describe 'DegreesToCompass component', ->
  c = null
  degrees = null
  heading = null
  beforeEach ->
    c = DegreesToCompass.getComponent()
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
    it 'should return NW for 300', (done) ->
      heading.once 'data', (data) ->
        chai.expect(data).to.equal 'NW'
        done()
      degrees.send 300
