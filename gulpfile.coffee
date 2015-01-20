gulp = require 'gulp'
del = require 'del'
stylus = require 'gulp-stylus'
bootstrap = require 'bootstrap-styl'
jade = require 'gulp-jade'

gulp.task 'clean:js', (cb) ->
  del 'assets/site.js', cb

gulp.task 'clean:css', (cb) ->
  del 'assets/site.css', cb

gulp.task 'clean:views', (cb) ->
  del '*.html', cb

gulp.task 'js', ['clean:js'], ->

gulp.task 'css', ['clean:css'], ->
  gulp.src('_styles/site.styl')
    .pipe stylus(use: bootstrap()).on('error', console.log)
    .pipe gulp.dest('assets')

gulp.task 'views', ['clean:views'], ->
  gulp.src('_views/index.jade')
    .pipe jade(pretty: true).on('error', console.log)
    .pipe gulp.dest('.')

gulp.task 'watch', ['default'], ->
  gulp.watch '_scripts/**/*', ['js']
  gulp.watch '_styles/**/*', ['css']
  gulp.watch '_views/**/*', ['views']

gulp.task 'default', ['js', 'css', 'views']

