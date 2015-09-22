require './test-case'
expect  = require('chai').expect
sinon   = require 'sinon'
promise = require 'promise'

View = require '../src/view'

describe 'View', ->
  beforeEach ->
    @clock = sinon.useFakeTimers()
    global.document.createElement.returns
      href: ''
      search: ''

  afterEach ->
    @clock.restore()

  it 'should use the default view duration', ->
    view = new View()
    expect(view._viewDuration).to.equal 7500

  it 'should use the provided view duration', ->
    config =
      'cortex.editorial.view.duration': 15000
    view = new View config
    expect(view._viewDuration).to.equal 15000

  describe '#prepare', ->
    it 'should call offer when no content is available', ->
      view = new View()
      offer = sinon.stub()
      get = sinon.stub view._feed, 'get', -> undefined
      view.prepare offer
      expect(get).to.have.been.calledOnce
      expect(offer).to.have.been.calledOnce
      expect(offer.args).to.deep.equal [[]]

    it 'should render the content for some time', ->
      view = new View()
      offer = sinon.stub()
      get = sinon.stub view._feed, 'get', -> 'image-url'
      render = sinon.stub view, '_render', ->
      view.prepare offer
      expect(get).to.have.been.calledOnce
      expect(offer).to.have.been.calledOnce
      cb = offer.args[0][0]
      done = sinon.stub()
      cb done
      expect(render).to.have.been.calledOnce
      expect(render).to.have.been.calledWith 'image-url'
      expect(done).to.not.have.been.called
      @clock.tick view._viewDuration
      expect(done).to.have.been.calledOnce
