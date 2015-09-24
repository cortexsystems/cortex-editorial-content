# Cortex Editorial Content [![Build Status](https://travis-ci.org/cortexsystems/cortex-editorial-content.svg?branch=master)](https://travis-ci.org/cortexsystems/cortex-editorial-content)
This application displayes editorial images from a set of RSS feeds. It requires Cortex Player v2+.

# Installation
```
npm install
make dist
```

Application zip file will appear under `./dist`.

# Configuration Parameters
  - `cortex.editorial.view.feeds`: A space separated list of RSS feeds.
  - `cortex.editorial.view.duration`: [default=7500] The duration an editorial image will be shown on screen in milliseconds.
  - `cortex.editorial.view.orientation`: [default=portrait] The orientation of the editorial images. Can be `portrait` or `landscape`.
  - `cortex.editorial.content.ttl`: [default=86400000] The duration an editorial image will get cached in milliseconds.
  - `cortex.editorial.feed.ttl`: [default=3600000] The duration an editorial RSS feed will get cached in milliseconds.
  - `cortex.editorial.feed.refreshInterval`: [default=3600000] Refresh interval of an RSS feed in milliseconds.
