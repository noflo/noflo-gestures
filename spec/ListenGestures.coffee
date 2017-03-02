noflo = require 'noflo'

describe 'ListenGestures subgraph', ->
  c = null
  element = null

  startEvents = [
    'start'
    'startpoint'
  ]
  uniqueEvents = [
    'elements'
  ]
  moveEvents = startEvents.concat [
    'speed'
    'distance'
    'angle'
    'movepoint'
    'current'
    'duration'
  ]
  endEvents = [
    'end'
    'endpoint'
  ]

  outPorts = moveEvents.concat uniqueEvents, endEvents
  data = null
  el = null
  before (done) ->
    data = {}
    loader = new noflo.ComponentLoader '/noflo-gestures'
    loader.load 'gestures/ListenGestures', (err, instance) ->
      return done err if err
      c = instance
      element = noflo.internalSocket.createSocket()
      c.once 'ready', ->
        c.network.on 'process-error', (err) ->
          setTimeout () ->
            throw err.error or err
          , 0
        outPorts.forEach (port) ->
          socket = noflo.internalSocket.createSocket()
          c.outPorts[port].attach socket
          socket.on 'data', (d) ->
            unless data[port]
              data[port] = []
            data[port].push d
        c.inPorts.element.attach element
        c.start done
  after (done) ->
    return done() unless c
    c.shutdown done
  createEvent = (target, type, details) ->
    evt = document.createEvent 'UIEvent'
    evt.initUIEvent type, true, true, window, 1
    for detail, value of details
      evt[detail] = value
    target.dispatchEvent evt

  describe 'on touch start', ->
    el = document.querySelector 'body'
    it 'should transmit the start element and start point', (done) ->
      element.send el
      createEvent el, 'pointerdown',
        clientX: 10
        clientY: 10
      setTimeout ->
        chai.expect(data).to.have.keys startEvents
        chai.expect(data.start[0]).to.eql el
        chai.expect(data.startpoint[0]).to.eql
          x: 10
          y: 10
        done()
      , 0

  describe 'on move', ->
    duration = null
    it 'should transmit a move event', (done) ->
      data = {}
      element.send el
      createEvent el, 'pointermove',
        clientX: 10
        clientY: 20
      setTimeout ->
        # Since we're passing the body only once, we won't get more of these
        chai.expect(data).to.have.keys moveEvents.concat [
          'elements'
        ]
        chai.expect(data.current[0]).to.eql el
        chai.expect(data.elements[0]).to.eql el
        chai.expect(data.start[0]).to.eql el
        chai.expect(data.angle[0]).to.equal 180
        chai.expect(data.distance[0]).to.equal 10
        chai.expect(data.duration[0]).to.be.at.least 2
        duration = data.duration[0]
        chai.expect(data.speed[0]).to.equal data.distance[0] / data.duration[0]
        chai.expect(data.startpoint[0]).to.eql
          x: 10
          y: 10
        chai.expect(data.movepoint[0]).to.eql
          x: 10
          y: 20
        setTimeout ->
          done()
        , 1
      , 0

    describe 'on another move', ->
      it 'should transmit a move event', (done) ->
        data = {}
        element.send el
        createEvent el, 'pointermove',
          clientX: 30
          clientY: 10
        setTimeout ->
          chai.expect(data).to.have.keys moveEvents
          chai.expect(data.current[0]).to.eql el
          chai.expect(data.start[0]).to.eql el
          chai.expect(data.angle[0]).to.equal 90
          chai.expect(data.distance[0]).to.equal 20
          chai.expect(data.duration[0]).to.be.above duration
          duration = data.duration[0]
          chai.expect(data.speed[0]).to.equal data.distance[0] / data.duration[0]
          chai.expect(data.startpoint[0]).to.eql
            x: 10
            y: 10
          chai.expect(data.movepoint[0]).to.eql
            x: 30
            y: 10
          done()
        , 0

    describe 'on end', ->
      it 'should transmit an end event', (done) ->
        data = {}
        element.send el
        createEvent el, 'pointerup',
          clientX: 20
          clientY: 10
        setTimeout ->
          chai.expect(data).to.have.keys endEvents
          chai.expect(data.end[0]).to.eql el
          chai.expect(data.endpoint[0]).to.eql
            x: 20
            y: 10
          done()
        , 0
