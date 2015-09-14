Feed = require './feed'

class View
  constructor: (@_config, @_url) ->
    @_feed = new Feed @_config, @_url

    @_viewDuration = @_config?['view.duration']
    @_viewDuration ?= 7500

  prepare: (offer) ->
    url = @_feed.get()
    if not not url
      @_render url
      offer (done) =>
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
      document.body.insertBefore div, document.body.firstChild

    div.style.setProperty(
      'background', "url(\"#{url}\") no-repeat center center local")

module.exports = View
