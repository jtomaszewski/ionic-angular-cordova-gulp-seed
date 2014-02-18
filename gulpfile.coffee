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
notify = require 'gulp-notify'
concat = require 'gulp-concat'
clean = require 'gulp-clean'

paths = 
  public: ['public/**']
  styles: ['app/css/**/*.scss']
  scripts: 
    vendor: [
      "public/components/ionic/release/js/ionic.js"
      "public/components/angular/angular.js"
      "public/components/angular-animate/angular-animate.js"
      "public/components/angular-sanitize/angular-sanitize.js"
      "public/components/angular-ui-router/release/angular-ui-router.js"
      "public/components/ionic/release/js/ionic-angular.js"
    ]
    app: ['app/js/**/*.coffee']
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

notifyGulpError = (pipe) ->
  pipe.on('error', notify.onError((error) -> 
    "Error: #{error.message}"
  ))

gulp.task 'clean', ->
  gulp.src('www', read: false)
    .pipe(clean())

gulp.task 'copy_public', ->
  gulp.src(paths.public)
    # .pipe(changed(destinations.public))
    .pipe(gulp.dest(destinations.public))


gulp.task 'styles', ->
  notifyGulpError gulp.src(paths.styles)
    # .pipe(changed(destinations.styles, extension: '.css'))
    .pipe(sass({
      errLogToConsole: true
      sourceComments: 'map'
    }))
    .pipe(gulp.dest(destinations.styles))


gulp.task 'scripts', ->
  notifyGulpError gulp.src(paths.scripts.vendor)
    .pipe(concat('vendor.js'))
    .pipe(gulp.dest(destinations.scripts))

  notifyGulpError gulp.src(paths.scripts.app)
    # .pipe(changed(destinations.scripts))
    # copy .coffee to www/ also, because sourcemap links to sources with relative path
    # .pipe(gulp.dest(destinations.scripts)) 
    .pipe(coffee({
      # sourcemaps arent ready for gulp-concat yet :/ lets wait with that
      sourceMap: false
    }))
    .pipe(concat('app.js'))
    .pipe(gulp.dest(destinations.scripts))


gulp.task 'templates', ->
  notifyGulpError gulp.src(paths.templates)
    .pipe(changed(destinations.templates, extension: '.html'))
    .pipe(jade({
      locals: {}
      pretty: true
    }))
    .pipe(gulp.dest(destinations.templates))


gulp.task 'watch', ->
  gulp.watch(paths.public, ['copy_public'])
  gulp.watch(paths.scripts.app, ['scripts'])
  gulp.watch(paths.scripts.vendor, ['scripts'])
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
  http.createServer(ecstatic(root: "www")).listen(options.httpPort)
  gutil.log gutil.colors.blue "HTTP server listening on #{options.httpPort}"
  if options.open
    url = "http://localhost:#{options.httpPort}/"
    open(url)
    gutil.log gutil.colors.blue "Opening #{url} in the browser..."


gulp.task 'default', [
  # 'clean'
  'copy_public'
  'styles'
  'scripts'
  'templates'
  'watch'
  'server'
]
