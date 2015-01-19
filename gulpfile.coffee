gulp = require('gulp')

gulp.task 'clean:js', ->

gulp.task 'clean:css', ->

gulp.task 'clean:views', ->

gulp.task 'js', ['clean:js'], ->

gulp.task 'css', ['clean:css'], ->

gulp.task 'views', ['clean:views'], ->

gulp.task 'watch', ['default'], ->

gulp.task 'default', ['js', 'css', 'views']

