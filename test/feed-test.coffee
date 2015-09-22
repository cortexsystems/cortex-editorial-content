require './test-case'
expect  = require('chai').expect
sinon   = require 'sinon'
promise = require 'promise'

Feed = require '../src/feed'

describe 'View', ->
  beforeEach ->
    @clock = sinon.useFakeTimers()
    global.document.createElement.returns
      href: ''
      search: ''

  afterEach ->
    @clock.restore()

  it 'should use the default config parameters', ->
    feed = new Feed()
    expect(feed._assetCacheTTL).to.equal 3600000
    expect(feed._feedCacheTTL).to.equal 3600000
    expect(feed._feedRefreshInterval).to.equal 3600000

  it 'should use config parameters', ->
    config =
      'cortex.editorial.content.ttl': 1000
      'cortex.editorial.feed.ttl': 2000
      'cortex.editorial.feed.refreshInterval': 3000
    feed = new Feed config
    expect(feed._assetCacheTTL).to.equal 1000
    expect(feed._feedCacheTTL).to.equal 2000
    expect(feed._feedRefreshInterval).to.equal 3000

  it 'should generate a feed url with caching parameters', ->
    config =
      'cortex.editorial.content.ttl': 1000
      'cortex.editorial.feed.ttl': 2000
      'cortex.editorial.feed.refreshInterval': 3000

    global.document.createElement.returns href: 'http://test-url'
    feed = new Feed config, 'http://test-url'
    expect(feed._url).to.equal(
      'http://test-url?crtx_mode=normal&crtx_strip=1&crtx_ttl=2000')

    global.document.createElement.returns
      href: 'http://test-url?q=a'
      search: 'q=a'

    feed = new Feed config, 'http://test-url?q=a'
    expect(feed._url).to.equal(
      'http://test-url?q=a&crtx_mode=normal&crtx_strip=1&crtx_ttl=2000')

  it 'should start the fetch timer', ->
    config =
      'cortex.editorial.content.ttl': 1000
      'cortex.editorial.feed.ttl': 2000
      'cortex.editorial.feed.refreshInterval': 3000
    expect(@clock.timers).to.not.be.ok
    feed = new Feed config
    expect(Object.keys(@clock.timers)).to.have.length 1
    timer = @clock.timers[Object.keys(@clock.timers)[0]]
    expect(timer.interval).to.equal 3000

  describe '#get', ->
    beforeEach ->
      @feed = new Feed()

    it 'should return undefined when there are no images', ->
      expect(@feed.get()).to.not.be.ok

    it 'should return one image at a time', ->
      @feed._images = ['a', 'b', 'c']
      expect(@feed._imageIndex).to.equal 0
      expect(@feed.get()).to.equal 'a'
      expect(@feed._imageIndex).to.equal 1
      expect(@feed.get()).to.equal 'b'
      expect(@feed._imageIndex).to.equal 2
      expect(@feed.get()).to.equal 'c'
      expect(@feed._imageIndex).to.equal 3
      expect(@feed.get()).to.equal 'a'
      expect(@feed._imageIndex).to.equal 1
