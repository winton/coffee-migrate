for key, value of require('./coffee-migrate/common')
  eval("var #{key} = value;")

module.exports = class CoffeeMigrate
  constructor: ->