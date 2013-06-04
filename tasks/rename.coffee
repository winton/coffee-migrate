# Ensure filenames are using the name defined in package.json.
# https://github.com/jdavis/grunt-rename

module.exports = (grunt) ->

  grunt.config.data.rename =
    bin_path:
      src : "bin/coffee-migrate"
      dest: "bin/<%= pkg.name %>"
    src_directory:
      src : "src/coffee-migrate"
      dest: "src/<%= pkg.name %>"
    src_path:
      src : "src/coffee-migrate.coffee"
      dest: "src/<%= pkg.name %>.coffee"

  grunt.loadNpmTasks "grunt-rename"