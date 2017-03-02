noflo = require 'noflo'

describe 'ListenPointer subgraph', ->
  c = null
  element = null
  start = null
  move = null
  end = null
  el = document.querySelector 'body'
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader '/noflo-gestures'
    loader.load 'gestures/ListenPointer', (err, instance) ->
      return done err if err
      c = instance
      c.once 'ready', ->
        c.network.on 'process-error', (err) ->
          setTimeout () ->
            throw err.error or err
          , 0
        element = noflo.internalSocket.createSocket()
        start = noflo.internalSocket.createSocket()
        move = noflo.internalSocket.createSocket()
        end = noflo.internalSocket.createSocket()
        c.inPorts.element.attach element
        c.outPorts.start.attach start
        c.outPorts.move.attach move
        c.outPorts.end.attach end
        c.start done
  after (done) ->
    return done() unless c
    c.shutdown done

  describe 'on down', ->
    it 'should transmit a start event', (done) ->
      @timeout 4000
      element.send el
      start.once 'data', (data) ->
        chai.expect(data.clientX).to.equal 10
        done()
      evt = document.createEvent 'UIEvent'
      evt.initUIEvent 'pointerdown', true, true, window, 1
      evt.clientX = 10
      evt.clientY = 10
      el.dispatchEvent evt

  describe 'on move', ->
    it 'should transmit a move event', (done) ->
      @timeout 4000
      element.send el
      move.once 'data', (data) ->
        chai.expect(data.clientX).to.equal 20
        done()
      evt = document.createEvent 'UIEvent'
      evt.initUIEvent 'pointermove', true, true, window, 1
      evt.clientX = 20
      evt.clientY = 10
      el.dispatchEvent evt

  describe 'on up', ->
    it 'should transmit an end event', (done) ->
      @timeout 4000
      element.send el
      end.once 'data', (data) ->
        chai.expect(data.clientX).to.equal 20
        done()
      evt = document.createEvent 'UIEvent'
      evt.initUIEvent 'pointerup', true, true, window, 1
      evt.clientX = 20
      evt.clientY = 10
      el.dispatchEvent evt
