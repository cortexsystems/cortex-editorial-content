gulp        = require 'gulp'
concat      = require 'gulp-concat'
browserify  = require 'gulp-browserify'
zip         = require 'gulp-zip'
jeditor     = require 'gulp-json-editor'
mocha       = require 'gulp-mocha'

Package     = require './package.json'

project =
  dist:         './dist'
  build:        './build'
  src:          './src/**/*.coffee'
  tests:        './test/**/*-test.coffee'
  static:       './static/**'
  assets_src:   './app_assets/**'
  assets_dest:  './build/app_assets'
  manifest:     './manifest.json'
  readme:       './README.md'
  changelog:    './CHANGELOG.md'

gulp.task 'default', ['pack']
gulp.task 'build', ['src', 'app_assets', 'static', 'readme', 'changelog',
  'manifest']

gulp.task 'src', ->
  gulp.src('./src/index.coffee',  read: false)
    .pipe(browserify({
      transform:  ['coffeeify']
      extensions: ['.coffee']
    }))
    .pipe(concat('app.js'))
    .pipe(gulp.dest(project.build))

gulp.task 'static', ->
  gulp.src(project.static)
    .pipe(gulp.dest(project.build))

gulp.task 'app_assets', ->
  gulp.src(project.assets_src)
    .pipe(gulp.dest(project.assets_dest))

gulp.task 'manifest', ->
  gulp.src(project.manifest)
    .pipe(jeditor((json) ->
      json.version = Package.version
      json
    )).pipe(gulp.dest(project.build))

gulp.task 'readme', ->
  gulp.src(project.readme)
    .pipe(gulp.dest(project.build))

gulp.task 'changelog', ->
  gulp.src(project.changelog)
    .pipe(gulp.dest(project.build))

gulp.task 'pack', ['build'], ->
  gulp.src("#{project.build}/**")
    .pipe(zip("#{Package.name}-#{Package.version}.zip"))
    .pipe(gulp.dest(project.dist))

gulp.task 'test', ->
  gulp.src(project.tests, read: false)
    .pipe(mocha(reporter: 'spec', timeout: 2000))
    .on 'error', (err) ->
      console.log(err.toString())
      @emit('end')
