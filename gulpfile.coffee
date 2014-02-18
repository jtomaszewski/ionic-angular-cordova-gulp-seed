gulp = require 'gulp'
gutil = require 'gulp-util'
sass = require 'gulp-sass'
coffee = require 'gulp-coffee'
jade = require 'gulp-jade'
livereload = require 'gulp-livereload'
changed = require 'gulp-changed'
ripple = require 'ripple-emulator'
open = require 'open'
http = require 'http'
path = require 'path'
ecstatic = require 'ecstatic'

paths = 
  public: ['public/**']
  styles: ['app/css/**/*.scss']
  scripts: ['app/js/**/*.coffee']
  templates: ['app/**/*.jade']

destinations = 
  public: 'www'
  styles: 'www/css'
  scripts: 'www/js'
  templates: 'www'

options = {
  open: false # open the server in the browser on init?
  httpPort: 4400
  riddlePort: 4400
}


gulp.task 'copy_public', ->
  gulp.src(paths.public)
    .pipe(changed(destinations.public))
    .pipe(gulp.dest(destinations.public))


gulp.task 'styles', ->
  gulp.src(paths.styles)
    .pipe(changed(destinations.styles, extension: '.css'))
    .pipe(sass({
      errLogToConsole: true, 
      sourceComments: 'map'
    }))
    .pipe(gulp.dest(destinations.styles))


gulp.task 'scripts', ->
  gulp.src(paths.scripts)
    .pipe(changed(destinations.scripts))
    # copy .coffee to www/ also, because .map files links to them them with relative path
    .pipe(gulp.dest(destinations.scripts)) 
    .pipe(coffee({
      sourceMap: true
    }))
    .pipe(gulp.dest(destinations.scripts))


gulp.task 'templates', ->
  gulp.src(paths.templates)
    .pipe(changed(destinations.templates, extension: '.html'))
    .pipe(jade({
      locals: {}
      pretty: true
    }))
    .pipe(gulp.dest(destinations.templates))


gulp.task 'watch', ->
  gulp.watch(paths.public, ['copy_public'])
  gulp.watch(paths.scripts, ['scripts'])
  gulp.watch(paths.styles, ['styles'])
  gulp.watch(paths.templates, ['templates'])

  livereloadServer = livereload()
  gulp.watch('www/**/*.css').on 'change', (file) ->
    livereloadServer.changed(file.path)


gulp.task 'emulator', ->
  ripple.emulate.start(options)
  gutil.log gutil.colors.blue "Ripple-Emulator listening on #{options.ripplePort}"
  if options.open
    url = "http://localhost:#{options.ripplePort}/?enableripple=cordova-3.0.0-HVGA"
    open(url)
    gutil.log gutil.colors.blue "Opening #{url} in the browser..."


gulp.task 'server', ->
  http.createServer(ecstatic(root: __dirname)).listen(options.httpPort)
  gutil.log gutil.colors.blue "HTTP server listening on #{options.httpPort}"
  if options.open
    url = "http://localhost:#{options.httpPort}/"
    open(url)
    gutil.log gutil.colors.blue "Opening #{url} in the browser..."


gulp.task 'default', [
  'copy_public'
  'styles'
  'scripts'
  'templates'
  'watch'
  'server'
]
