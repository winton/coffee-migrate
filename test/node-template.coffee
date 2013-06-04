CoffeeMigrate  = require("../lib/coffee-migrate")
node_template = null

describe 'CoffeeMigrate', ->
  describe '#constructor', ->
    before ->
      node_template = new CoffeeMigrate

    it 'should return an instance of CoffeeMigrate', ->
      node_template.should.be.an.instanceof(CoffeeMigrate)