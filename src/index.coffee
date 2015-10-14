View = require './view'

init = ->
  window.addEventListener 'cortex-ready', ->
    window.Cortex.app.getConfig()
      .then (config) ->
        feeds = config['cortex.editorial.view.feeds']
        urls = []
        for feed in feeds?.split(' ')
          feed = feed.trim()
          if not not feed
            urls.push feed

        if urls.length == 0
          throw new Error('No RSS feeds provided. Application cannot run.')

        rotate = JSON.parse config['cortex.editorial.rotate']
        if rotate
          link = window.document.createElement 'link'
          link.setAttribute 'rel', 'stylesheet'
          link.setAttribute 'href', 'rotate.css'
          window.document.body.appendChild link

        window.EditorialView = new View config, urls
        window.Cortex.scheduler.onPrepare window.EditorialView.prepare
      .catch (e) ->
        console.error 'Failed to initialize the application.', e
        throw e

module.exports = init()
