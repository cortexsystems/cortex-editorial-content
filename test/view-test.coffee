require './test-case'
expect  = require('chai').expect
sinon   = require 'sinon'
promise = require 'promise'

View = require '../src/view'

describe 'View', ->
  beforeEach ->
    @clock = sinon.useFakeTimers()
    global.document =
      createElement: sinon.stub().returns
        href: ''
        search: ''
      getElementById: sinon.stub()
      removeChild: sinon.stub()

  afterEach ->
    @clock.restore()

  it 'should use the default view duration', ->
    view = new View {}, []
    expect(view._viewDuration).to.equal 7500

  it 'should use the provided view duration', ->
    config =
      'cortex.editorial.view.duration': 15000
    view = new View config, []
    expect(view._viewDuration).to.equal 15000

  describe '#prepare', ->
    it 'should call offer when there are no feeds', ->
      view = new View {}, []
      offer = sinon.stub()
      view.prepare offer
      expect(offer).to.have.been.calledOnce
      expect(offer.args).to.deep.equal [[]]

    it 'should call offer when there is no content available', ->
      view = new View {}, ['url']
      expect(view._feedIndex).to.equal 0
      get = sinon.stub view._feeds[0], 'get', -> undefined
      offer = sinon.stub()
      view.prepare offer
      expect(get).to.have.been.calledOnce
      expect(view._feedIndex).to.equal 1
      expect(offer).to.have.been.calledOnce
      expect(offer.args).to.deep.equal [[]]

    it 'should create the dom node when there is content', ->
      view = new View {}, ['url']
      get = sinon.stub view._feeds[0], 'get', -> 'view-url'
      createDOMNode = sinon.stub view, '_createDOMNode'
      offer = sinon.stub()
      view.prepare offer
      expect(get).to.have.been.calledOnce
      expect(view._feedIndex).to.equal 1
      expect(createDOMNode).to.have.been.calledOnce
      expect(createDOMNode.args[0][1]).to.equal 'view-url'
      expect(offer).to.have.been.calledOnce

    it 'should hide the previous image before showing the new one', ->
      view = new View {}, ['url']
      get = sinon.stub view._feeds[0], 'get', -> 'view-url'
      createDOMNode = sinon.stub view, '_createDOMNode'
      offer = sinon.stub()
      removeChild = sinon.stub()
      global.document.getElementById.withArgs('content').returns
        removeChild: removeChild
      view._prev = 'prev-url'
      view.prepare offer
      expect(get).to.have.been.calledOnce
      expect(view._feedIndex).to.equal 1
      expect(createDOMNode).to.have.been.calledOnce
      expect(createDOMNode.args[0][1]).to.equal 'view-url'
      expect(offer).to.have.been.calledOnce
      setProperty = sinon.stub()
      global.document.getElementById.withArgs('prev-url').returns
        style:
          setProperty: setProperty
      cb = offer.args[0][0]
      done = sinon.stub()
      cb done
      expect(view._prev).to.equal undefined
      expect(removeChild).to.have.been.calledOnce

    it 'should call the end callback immediately when new image node doesnt \
        exist', ->
      view = new View {}, ['url']
      get = sinon.stub view._feeds[0], 'get', -> 'view-url'
      createDOMNode = sinon.stub view, '_createDOMNode'
      offer = sinon.stub()
      view._prev = 'prev-url'
      removeChild = sinon.stub()
      global.document.getElementById.withArgs('content').returns
        removeChild: removeChild
      view.prepare offer
      expect(get).to.have.been.calledOnce
      expect(view._feedIndex).to.equal 1
      expect(createDOMNode).to.have.been.calledOnce
      expect(createDOMNode.args[0][1]).to.equal 'view-url'
      expect(offer).to.have.been.calledOnce
      global.document.getElementById.withArgs('view-url').returns undefined
      cb = offer.args[0][0]
      done = sinon.stub()
      cb done
      # Only the timer set by the Feed class
      expect(Object.keys(@clock.timers).length).to.equal 1
      expect(view._prev).to.equal undefined
      # getElementById('prev-url') will return undefined.
      expect(removeChild).to.not.have.been.called

    it 'should call the end callback after some time when new image node \
        exists', ->
      view = new View {}, ['url']
      get = sinon.stub view._feeds[0], 'get', -> 'view-url'
      createDOMNode = sinon.stub view, '_createDOMNode'
      offer = sinon.stub()
      view._prev = 'prev-url'
      removeChild = sinon.stub()
      global.document.getElementById.withArgs('content').returns
        removeChild: removeChild
      view.prepare offer
      expect(get).to.have.been.calledOnce
      expect(view._feedIndex).to.equal 1
      expect(createDOMNode).to.have.been.calledOnce
      expect(createDOMNode.args[0][1]).to.equal 'view-url'
      expect(offer).to.have.been.calledOnce
      setProperty = sinon.stub()
      global.document.getElementById.withArgs('view-url').returns
        style:
          setProperty: setProperty
      cb = offer.args[0][0]
      done = sinon.stub()
      cb done
      expect(Object.keys(@clock.timers).length).to.equal 2
      expect(done).to.not.have.been.called
      expect(setProperty).to.have.been.calledOnce
      expect(setProperty).to.have.been.calledWith 'z-index', 9999
      @clock.tick view._viewDuration
      expect(done).to.have.been.calledOnce
      expect(view._prev).to.equal 'view-url'
