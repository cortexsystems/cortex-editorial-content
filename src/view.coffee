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

  prepare: (offer) =>
    if not @_feeds or @_feeds.length == 0
      offer()
      return

    if @_feedIndex >= @_feeds.length
      @_feedIndex = 0

    feed = @_feeds[@_feedIndex]
    @_feedIndex += 1

    container = document.getElementById 'content'
    url = feed.get()
    if not not url
      @_createDOMNode container, url

      offer (done) =>
        if @_prev?
          prev = document.getElementById @_prev
          if prev?
            container.removeChild prev
          @_prev = undefined

        img = document.getElementById url
        if img?
          img.style.setProperty 'z-index', 9999
          end = =>
            @_prev = url
            done()
          setTimeout end, @_viewDuration
        else
          done()
    else
      offer()

  _createDOMNode: (container, url) ->
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

module.exports = View
