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
      expect(view._active).to.be.undefined
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
      expect(view._active).to.be.undefined
      expect(createDOMNode).to.have.been.calledOnce
      expect(createDOMNode).to.have.been.calledWith 'view-url'
      expect(offer).to.have.been.calledOnce

    it 'should hide the previous image before showing the new one', ->
      view = new View {}, ['url']
      get = sinon.stub view._feeds[0], 'get', -> 'view-url'
      createDOMNode = sinon.stub view, '_createDOMNode'
      offer = sinon.stub()
      view._prev = 'prev-url'
      view.prepare offer
      expect(get).to.have.been.calledOnce
      expect(view._feedIndex).to.equal 1
      expect(view._active).to.be.undefined
      expect(createDOMNode).to.have.been.calledOnce
      expect(createDOMNode).to.have.been.calledWith 'view-url'
      expect(offer).to.have.been.calledOnce
      setProperty = sinon.stub()
      global.document.getElementById.withArgs('prev-url').returns
        style:
          setProperty: setProperty
      cb = offer.args[0][0]
      done = sinon.stub()
      cb done
      expect(setProperty).to.have.been.calledOnce
      expect(setProperty).to.have.been.calledWith 'z-index', -9999

    it 'should call the end callback immediately when new image node doesnt \
        exist', ->
      view = new View {}, ['url']
      get = sinon.stub view._feeds[0], 'get', -> 'view-url'
      createDOMNode = sinon.stub view, '_createDOMNode'
      offer = sinon.stub()
      view._prev = 'prev-url'
      view.prepare offer
      expect(get).to.have.been.calledOnce
      expect(view._feedIndex).to.equal 1
      expect(view._active).to.be.undefined
      expect(createDOMNode).to.have.been.calledOnce
      expect(createDOMNode).to.have.been.calledWith 'view-url'
      expect(offer).to.have.been.calledOnce
      global.document.getElementById.withArgs('view-url').returns undefined
      cb = offer.args[0][0]
      done = sinon.stub()
      cb done
      expect(view._active).to.be.undefined
      # Only the timer set by the Feed class
      expect(Object.keys(@clock.timers).length).to.equal 1

    it 'should call the end callback after some time when new image node \
        exists', ->
      view = new View {}, ['url']
      get = sinon.stub view._feeds[0], 'get', -> 'view-url'
      createDOMNode = sinon.stub view, '_createDOMNode'
      offer = sinon.stub()
      view._prev = 'prev-url'
      view.prepare offer
      expect(get).to.have.been.calledOnce
      expect(view._feedIndex).to.equal 1
      expect(view._active).to.be.undefined
      expect(createDOMNode).to.have.been.calledOnce
      expect(createDOMNode).to.have.been.calledWith 'view-url'
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
      expect(view._active).to.equal 'view-url'
      expect(setProperty).to.have.been.calledOnce
      expect(setProperty).to.have.been.calledWith 'z-index', 9999
      @clock.tick view._viewDuration
      expect(done).to.have.been.calledOnce
      expect(view._active).to.be.undefined
      expect(view._prev).to.equal 'view-url'

  describe '#_onNewImages', ->
    it 'should delete the old images that are not in the new list', ->
      view = new View {}, []
      del = sinon.stub view, '_delete'

      view._onNewImages ['a', 'b', 'c'], ['a', 'd', 'e']
      expect(del).to.have.been.calledTwice
      expect(del.args[0][1]).to.equal 'b'
      expect(del.args[1][1]).to.equal 'c'

  describe '#_delete', ->
    it 'should delete the given image when its not active', ->
      view = new View {}, []
      expect(view._active).to.be.undefined
      view._nodes =
        a: 'node'
      global.document.getElementById.returns 'dom-node'
      container =
        removeChild: sinon.stub()
      view._delete container, 'a'
      expect(view._nodes).to.deep.equal {}
      expect(global.document.getElementById).to.have.been.calledOnce
      expect(global.document.getElementById).to.have.been.calledWith 'a'
      expect(container.removeChild).to.have.been.calledOnce
      expect(container.removeChild).to.have.been.calledWith 'dom-node'

    it 'should schedule a new delete when asked url is active', ->
      view = new View {}, ['url']
      view._nodes =
        a: 'node'
      view._active = 'a'
      global.document.getElementById.returns 'dom-node'
      container =
        removeChild: sinon.stub()
      expect(Object.keys(@clock.timers).length).to.equal 1
      view._delete container, 'a'
      expect(view._nodes).to.deep.equal
        a: 'node'
      expect(global.document.getElementById).to.not.have.been.called
      expect(container.removeChild).to.not.have.been.called
      expect(Object.keys(@clock.timers)).to.have.length 2
      view._active = undefined
      @clock.tick 2000
      expect(view._nodes).to.deep.equal {}
      expect(global.document.getElementById).to.have.been.calledOnce
      expect(global.document.getElementById).to.have.been.calledWith 'a'
      expect(container.removeChild).to.have.been.calledOnce
      expect(container.removeChild).to.have.been.calledWith 'dom-node'
