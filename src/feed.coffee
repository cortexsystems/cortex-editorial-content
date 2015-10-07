promise = require 'promise'
$       = require 'jquery'

class Feed
  constructor: (@_config, url, @_onNewImages) ->
    @_imageIndex = 0
    @_images = []

    @_requestThrottleMs = 500

    @_assetCacheTTL = @_config?['cortex.editorial.content.ttl']
    @_assetCacheTTL ?= 3600000

    @_feedCacheTTL = @_config?['cortex.editorial.feed.ttl']
    @_feedCacheTTL ?= 3600000

    @_feedRefreshInterval = @_config?['cortex.editorial.feed.refreshInterval']
    @_feedRefreshInterval ?= 3600000

    @_url = @_generateCortexUrl url

    console.log "Feed processor starts with url=#{@_url}, \
      assetCacheTTL=#{@_assetCacheTTL}, feedCacheTTL=#{@_feedCacheTTL}, \
      feedRefreshInterval=#{@_feedRefreshInterval}"

    @_fetch()
    setInterval @_fetch, @_feedRefreshInterval

  get: ->
    image = undefined
    if @_images? and @_images.length > 0
      if @_imageIndex >= @_images.length
        @_imageIndex = 0

      image = @_images[@_imageIndex]
      @_imageIndex += 1

    image

  _fetch: =>
    new promise (resolve, reject) =>
      $.get(@_url, (data) =>
        urls = @_parse data
        if urls? and urls.length > 0
          console.log "Found images: #{@_images.length} -> #{urls.length}"
          promises = (@_cache(url, i * @_requestThrottleMs) for url, i in urls)
          promise.all promises
            .then (res) =>
              @_onNewImages @_images, res
              @_images = res
              resolve()
            .catch (e) ->
              console.error "Failed to cache images.", e
              reject e
      ).fail (xhr, status, err) =>
        console.error "Failed to fetch xml feed #{@_url}. s=#{status}", err
        reject err

  _parse: (data) ->
    xml = $(data)
    items = xml.find('item')
    images = []
    for item in items
      item = $(item)
      img = item.find('media\\:content, content')
      url = img.attr('url')
      images.push url

    console.log "Feed parsed: Total images found: #{images.length}"
    images

  _cache: (image, wait=0) ->
    new promise (resolve, reject) =>
      opts =
        cache:
          mode: 'normal'
          ttl:  @_assetCacheTTL

      fetch = ->
        window.Cortex.net.get image, opts
          .then ->
            resolve image
          .catch reject

      setTimeout fetch, wait

  _generateCortexUrl: (url) ->
    el = document.createElement 'a'
    el.href = url

    if not not el.search
      "#{url}&crtx_mode=normal&crtx_strip=1&crtx_ttl=#{@_feedCacheTTL}"
    else
      "#{url}?crtx_mode=normal&crtx_strip=1&crtx_ttl=#{@_feedCacheTTL}"

module.exports = Feed
