var gulp = require('gulp'),
    rename = require('gulp-rename'),
    cleancss = require('gulp-clean-css'),
    concat = require('gulp-concat'),
    elm = require('gulp-elm'),
    uglify = require('gulp-uglify'),
    del = require('del')
    gzip = require('gulp-gzip');

var build = {
    styles: {
        sources: ['src/*.css', 'bower_components/bootstrap/dist/css/bootstrap.css', 'bower_components/bootstrap/dist/css/bootstrap-theme.css', 'bower_components/highlightjs/styles/color-brewer.css'],
        target: './dist'
    },

    scripts: {
        elm: 'src/Main.elm',
        sources: ['src/*.js', 'bower_components/jquery/dist/jquery.js', 'bower_components/bootstrap/dist/js/bootstrap.js', 'bower_components/highlightjs/highlight.pack.js'],
        target: './dist'
    },

    elm: {
        sources: 'src/Main.elm',
        target: './src'
    },

    html: {
        sources: ['src/*.html'],
        target: './dist'
    }
};

gulp.task('styles', function () {
    return gulp.src(build.styles.sources)
        .pipe(concat('styles.css'))
        .pipe(rename({ suffix: '.min' }))
        .pipe(cleancss())
        .pipe(gulp.dest(build.styles.target));
});

gulp.task('elm-init', elm.init);

gulp.task('elm', ['elm-init'], function () {
    return gulp.src(build.elm.sources)
        .pipe(elm.bundle('Main.js'))
        .pipe(gulp.dest(build.elm.target));
});

gulp.task('scripts', ['elm'], function () {
    return gulp.src(build.scripts.sources)
        .pipe(concat('bitdoc.js'))
        .pipe(rename({ suffix: '.min' }))
        .pipe(uglify())
        .pipe(gulp.dest(build.scripts.target))
});


gulp.task('html', function () {
    return gulp.src(build.html.sources)
        .pipe(gulp.dest(build.html.target));
});

gulp.task('clean', function (cb) {
    return del([build.styles.target, build.scripts.target]);
});


gulp.task('compress', ['styles', 'scripts', 'html'], function () {
    return gulp.src('./dist/*')
    .pipe(gzip())
    .pipe(gulp.dest('./dist'));
});

gulp.task('default', ['clean', 'compress']);
