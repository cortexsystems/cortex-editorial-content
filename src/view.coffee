Feed = require './feed'

class View
  constructor: (@_config, @_url) ->
    @_feed = new Feed @_config, @_url

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
    div = document.getElementById 'content-div'
    if not div
      div = document.createElement 'div'
      div.setAttribute 'id', 'content-div'
      div.style.setProperty 'width', '100%'
      div.style.setProperty 'height', '100%'
      div.style.setProperty 'overflow', 'hidden'
      document.body.insertBefore div, document.body.firstChild

    div.style.setProperty 'background', "url(\"#{url}\")"
    div.style.setProperty 'background-repeat', 'no-repeat'
    div.style.setProperty 'background-position', '50% 50%'
    div.style.setProperty 'background-size', 'contain'

module.exports = View
