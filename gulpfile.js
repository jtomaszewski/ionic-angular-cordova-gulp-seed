var gulp = require('gulp'),
    gutil = require('gulp-util'),
    sass = require('gulp-sass'),
    coffee = require('gulp-coffee'),
    jade = require('gulp-jade'),
    livereload = require('gulp-livereload'),
    changed = require('gulp-changed'),
    ripple = require('ripple-emulator'),
    open = require('open'),
    http = require('http'),
    path = require('path'),
    ecstatic = require('ecstatic'),
    notify = require('gulp-notify'),
    concat = require('gulp-concat'),
    clean = require('gulp-clean'),
    runSequence = require('run-sequence');

var paths = {
  "public": ['public/**'],
  styles: ['app/css/**/*.scss'],
  scripts: {
    vendor: ["public/components/ionic/release/js/ionic.js", "public/components/angular/angular.js", "public/components/angular-animate/angular-animate.js", "public/components/angular-sanitize/angular-sanitize.js", "public/components/angular-ui-router/release/angular-ui-router.js", "public/components/ionic/release/js/ionic-angular.js"],
    app: ['app/js/**/*.coffee']
  },
  templates: ['app/**/*.jade']
};

var destinations = {
  "public": 'www',
  styles: 'www/css',
  scripts: 'www/js',
  templates: 'www',
  livereload: ['www/**']
};

var options = {
  open: true,
  httpPort: 4400,
  riddlePort: 4400
};

gulp.task('clean', function() {
  return gulp.src('www', {
    read: false
  })
    .pipe(clean());
});

gulp.task('copy_public', function() {
  return gulp.src(paths["public"])
    .pipe(gulp.dest(destinations["public"]));
});

gulp.task('styles', function() {
  return gulp.src(paths.styles)
    .pipe(sass({
      errLogToConsole: true,
      sourceComments: 'map'
    }))
    .pipe(gulp.dest(destinations.styles));
});

gulp.task('scripts', function() {
  gulp.src(paths.scripts.vendor)
    .pipe(concat('vendor.js'))
    .pipe(gulp.dest(destinations.scripts));

  return gulp.src(paths.scripts.app)
    .pipe(coffee({
      sourceMap: false
    }))
    .pipe(concat('app.js'))
    .pipe(gulp.dest(destinations.scripts));
});

gulp.task('templates', function() {
  return gulp.src(paths.templates)
    .pipe(changed(destinations.templates, {
      extension: '.html'
    }))
    .pipe(jade({
      locals: {},
      pretty: true
    }))
    .pipe(gulp.dest(destinations.templates));
});

gulp.task('watch', function() {
  var livereloadServer = livereload();

  gulp.watch(paths["public"], ['copy_public']);
  gulp.watch(paths.scripts.app, ['scripts']);
  gulp.watch(paths.scripts.vendor, ['scripts']);
  gulp.watch(paths.styles, ['styles']);
  gulp.watch(paths.templates, ['templates']);

  return gulp.watch(destinations.livereload).on('change', function(file) {
    return livereloadServer.changed(file.path);
  });
});

gulp.task('emulator', function() {
  var url = "http://localhost:" + options.ripplePort + "/?enableripple=cordova-3.0.0-HVGA";

  ripple.emulate.start(options);

  gutil.log(gutil.colors.blue("Ripple-Emulator listening on " + options.ripplePort));

  if (options.open) {
    open(url);
    return gutil.log(gutil.colors.blue("Opening " + url + " in the browser..."));
  }
});

gulp.task('server', function() {
  var url = "http://localhost:" + options.httpPort + "/";

  http.createServer(ecstatic({
    root: "www"
  })).listen(options.httpPort);

  gutil.log(gutil.colors.blue("HTTP server listening on " + options.httpPort));

  if (options.open) {
    open(url);
    return gutil.log(gutil.colors.blue("Opening " + url + " in the browser..."));
  }
});

gulp.task('build', function(cb) {
  return runSequence(
    'clean', 
    ['copy_public', 'styles', 'scripts', 'templates'], 
    cb
  );
});

gulp.task('default', function(cb) {
  return runSequence(
    'build', 
    ['watch', 'server'],
    cb
  );
});
