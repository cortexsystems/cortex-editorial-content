View = require './view'

init = ->
  window.addEventListener 'cortex-ready', ->
    window.Cortex.app.getConfig()
      .then (config) ->
        feeds = config['cortex.editorial.view.feeds']
        views = []
        for feed in feeds?.split(' ')
          feed = feed.trim()
          if not feed
            continue

          views.push new View config, feed

        if views.length == 0
          throw new Error('No RSS feeds provided. Application cannot run.')

        # Make views accesible on dev console.
        window.EditorialViews = views

        viewIndex = 0
        window.Cortex.scheduler.onPrepare (offer) ->
          if viewIndex >= views.length
            viewIndex = 0

          view = views[viewIndex]
          view.prepare offer
          viewIndex += 1

      .catch (e) ->
        console.error 'Failed to initialize the application.', e
        throw e

module.exports = init()
