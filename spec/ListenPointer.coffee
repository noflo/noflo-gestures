noflo = require 'noflo'

describe 'ListenPointer subgraph', ->
  c = null
  element = null
  start = null
  move = null
  end = null
  el = document.querySelector 'body'
  before (done) ->
    loader = new noflo.ComponentLoader '/noflo-gestures'
    loader.load 'gestures/ListenPointer', (err, instance) ->
      return done err if err
      c = instance
      element = noflo.internalSocket.createSocket()
      start = noflo.internalSocket.createSocket()
      move = noflo.internalSocket.createSocket()
      end = noflo.internalSocket.createSocket()
      c.inPorts.element.attach element
      c.outPorts.start.attach start
      c.outPorts.move.attach move
      c.outPorts.end.attach end
      done()

  describe 'on down', ->
    it 'should transmit a start event', (done) ->
      element.send el
      start.once 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.clientX).to.equal 10
        done()
      evt = document.createEvent 'UIEvent'
      evt.initUIEvent 'mousedown', true, true, window, 1
      evt.clientX = 10
      evt.clientY = 10
      el.dispatchEvent evt

  describe 'on move', ->
    it 'should transmit a move event', (done) ->
      element.send el
      move.once 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.clientX).to.equal 20
        done()
      evt = document.createEvent 'UIEvent'
      evt.initUIEvent 'mousemove', true, true, window, 1
      evt.clientX = 20
      evt.clientY = 10
      el.dispatchEvent evt

  describe 'on up', ->
    it 'should transmit an end event', (done) ->
      element.send el
      end.once 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.clientX).to.equal 20
        done()
      evt = document.createEvent 'UIEvent'
      evt.initUIEvent 'mouseup', true, true, window, 1
      evt.clientX = 20
      evt.clientY = 10
      el.dispatchEvent evt

  after ->
    return unless c
    c.shutdown()
