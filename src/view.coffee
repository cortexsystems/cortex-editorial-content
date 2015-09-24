Feed = require './feed'

class View
  constructor: (@_config, @_url) ->
    @_feed = new Feed @_config, @_url

    @_orientation = @_config?['cortex.editorial.view.orientation']
    if @_orientation != 'portrait' and @_orientation != 'landscape'
      @_orientation = 'portrait'

    @_viewDuration = @_config?['cortex.editorial.view.duration']
    @_viewDuration ?= 7500

  prepare: (offer) ->
    url = @_feed.get()
    if not not url
      offer (done) =>
        @_render url
        setTimeout done, @_viewDuration
    else
      offer()

  _render: (url) ->
    container = document.getElementById 'content'
    img = document.getElementById 'img'
    if not img
      img = new Image()
      img.setAttribute 'id', 'img'
      switch @_orientation
        when 'landscape'
          img.style.setProperty 'width', '100%'
          img.style.setProperty 'height', 'auto'
        else
          img.style.setProperty 'width', 'auto'
          img.style.setProperty 'height', '100%'
      img.style.setProperty 'display', 'inner-block'
      container.insertBefore img, container.firstChild
    img.src = url

module.exports = View
