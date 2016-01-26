# Cortex Editorial Content
This application displays editorial images from a set of RSS feeds.

> Requires Cortex Player v2+.

Application will parse the `media:content` attribute of items to get the editorial images.

## Caching
Each RSS feed will be cached for `cortex.editorial.feed.ttl` milliseconds. Also, the application will try to refresh the RSS feed contents every `cortex.editorial.feed.refreshInterval` milliseconds. If for some reason, the application couldn't refresh the feed, it will use the cached copy.

Editorial images will be cached for `cortex.editorial.content.ttl` milliseconds.

## Configuration Parameters
  - `cortex.editorial.view.feeds`: A space separated list of RSS feeds.
  - `cortex.editorial.view.duration`: [default=7500] The duration an editorial image will be shown on screen in milliseconds.
  - `cortex.editorial.view.orientation`: [default=portrait] The orientation of the editorial images. Can be `portrait` or `landscape`.
  - `cortex.editorial.content.ttl`: [default=86400000] The duration an editorial image will get cached in milliseconds.
  - `cortex.editorial.feed.ttl`: [default=3600000] The duration an editorial RSS feed will get cached in milliseconds.
  - `cortex.editorial.feed.refreshInterval`: [default=3600000] Refresh interval of an RSS feed in milliseconds.

## Installation [![Build Status](https://travis-ci.org/cortexsystems/cortex-editorial-content.svg?branch=master)](https://travis-ci.org/cortexsystems/cortex-editorial-content)
```
npm install
make dist
```

Application zip file will appear under `./dist`.
