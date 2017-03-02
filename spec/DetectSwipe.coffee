noflo = require 'noflo'

describe 'DetectSwipe subgraph', ->
  c = null
  ins = null
  speed = null
  distance = null
  pass = null
  fail = null
  beforeEach (done) ->
    loader = new noflo.ComponentLoader '/noflo-gestures'
    loader.load 'gestures/DetectSwipe', (err, instance) ->
      return done err if err
      c = instance
      c.once 'ready', ->
        c.network.on 'process-error', (err) ->
          setTimeout () ->
            throw err.error or err
          , 0
        ins = noflo.internalSocket.createSocket()
        speed = noflo.internalSocket.createSocket()
        distance = noflo.internalSocket.createSocket()
        pass = noflo.internalSocket.createSocket()
        fail = noflo.internalSocket.createSocket()
        c.inPorts.in.attach ins
        c.inPorts.speed.attach speed
        c.inPorts.distance.attach distance
        c.outPorts.pass.attach pass
        c.outPorts.fail.attach fail
        c.start done

  describe 'with a valid swipe', ->
    it 'should pass', (done) ->
      expected =
        1:
          speed: 2.5
          distance: 60

      pass.on 'data', (data) ->
        chai.expect(data).to.eql expected
        done()
      fail.once 'data', (data) ->
        done new Error "Expected pass, got #{JSON.stringify(data)}"

      speed.send 2
      distance.send 40
      ins.send expected

  describe 'with an invalid swipe by speed', ->
    it 'should pass', (done) ->
      expected =
        1:
          speed: 2.5
          distance: 60

      fail.on 'data', (data) ->
        chai.expect(data).to.eql expected
        done()

      speed.send 3
      distance.send 40
      ins.send expected

  describe 'with an invalid swipe by distance', ->
    it 'should pass', (done) ->
      expected =
        1:
          speed: 2.5
          distance: 60

      fail.on 'data', (data) ->
        chai.expect(data).to.eql expected
        done()

      speed.send 2.5
      distance.send 100
      ins.send expected
