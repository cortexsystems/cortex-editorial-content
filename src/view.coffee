Feed = require './feed'

class View
  constructor: (@_config, @_urls) ->

    @_orientation = @_config?['cortex.editorial.view.orientation']
    if @_orientation != 'portrait' and @_orientation != 'landscape'
      @_orientation = 'portrait'

    @_viewDuration = @_config?['cortex.editorial.view.duration']
    @_viewDuration ?= 7500

    @_feeds = []
    for url in @_urls
      @_feeds.push new Feed @_config, url, @_onNewImages

    @_feedIndex = 0
    @_prev = undefined
    @_active = undefined
    @_nodes = {}

  prepare: (offer) =>
    if not @_feeds or @_feeds.length == 0
      offer()
      return

    if @_feedIndex >= @_feeds.length
      @_feedIndex = 0

    feed = @_feeds[@_feedIndex]
    @_feedIndex += 1

    url = feed.get()
    if not not url
      if not (url of @_nodes)
        @_createDOMNode url

      offer (done) =>
        if @_prev?
          prev = document.getElementById @_prev
          prev?.style.setProperty 'z-index', -9999

        img = document.getElementById url
        if img?
          @_active = url
          img.style.setProperty 'z-index', 9999
          end = =>
            @_active = undefined
            @_prev = url
            done()
          setTimeout end, @_viewDuration
        else
          done()
    else
      offer()

  _onNewImages: (oldImages, newImages) =>
    nis = {}
    for url in newImages
      nis[url] = true

    container = document.getElementById 'content'
    for url in oldImages
      if not (url of nis)
        @_delete container, url

  _delete: (container, url) ->
    if @_active == url
      del = =>
        @_delete container, url
      setTimeout del, 2000
      return

    delete @_nodes[url]
    node = document.getElementById url
    if node?
      container.removeChild node

  _createDOMNode: (url) ->
    container = document.getElementById 'content'
    img = new Image()
    img.id = url
    switch @_orientation
      when 'landscape'
        img.style.setProperty 'width', '100%'
        img.style.setProperty 'height', 'auto'
      else
        img.style.setProperty 'width', 'auto'
        img.style.setProperty 'height', '100%'
    img.src = url
    container.appendChild img
    @_nodes[url] = img

module.exports = View
