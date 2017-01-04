noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-gestures'

describe 'DegreesToCompass component', ->
  c = null
  degrees = null
  heading = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'gestures/DegreesToCompass', (err, instance) ->
      return done err if err
      c = instance
      degrees = noflo.internalSocket.createSocket()
      c.inPorts.degrees.attach degrees
      done()
  beforeEach ->
    heading = noflo.internalSocket.createSocket()
    c.outPorts.heading.attach heading
  afterEach ->
    c.outPorts.heading.detach heading

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
