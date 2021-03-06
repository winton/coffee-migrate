# Ensure file contents are using the name defined in package.json.
# https://github.com/yoniholmes/grunt-text-replace

module.exports = (grunt) ->

  grunt.util.toCamel = (str) ->
    str.replace /((^|\-)[a-z])/g, ($1) -> $1.toUpperCase().replace('-','')

  grunt.config.data.replace =
    dashed_paths:
      overwrite   : true
      replacements: [ from: /coffee-migrate/g, to: "<%= pkg.name %>" ]
      src         : replace_paths = [
        "bin/*"
        "Gruntfile.coffee"
        "package.json"
        "src/**/*.coffee"
        "tasks/**/*.coffee"
        "test/**/*.coffee"
      ]
    class_variables:
      overwrite   : true
      replacements: [ from: /CoffeeMigrate/g, to: "<%= grunt.util.toCamel(pkg.name) %>" ]
      src         : replace_paths

  grunt.loadNpmTasks "grunt-text-replace"