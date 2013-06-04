fs      = require("fs")
migrate = require("../lib/migrate")

db  = pets: []
set = null

describe 'Migrate', ->
  describe '#constructor', ->
    before ->
      try fs.unlinkSync(__dirname + "/.migrate")

      migrate(__dirname + "/.migrate")

      migrate "add guy ferrets", ((next) ->
        db.pets.push name: "tobi"
        db.pets.push name: "loki"
        next()
      ), (next) ->
        db.pets.pop()
        db.pets.pop()
        next()

      migrate "add girl ferrets", ((next) ->
        db.pets.push name: "jane"
        next()
      ), (next) ->
        db.pets.pop()
        next()

      migrate "add emails", ((next) ->
        db.pets.forEach (pet) ->
          pet.email = pet.name + "@learnboost.com"

        next()
      ), (next) ->
        db.pets.forEach (pet) ->
          delete pet.email

        next()

    it "should", (done) ->
      set = migrate()
      set.up ->
        assertPets()
        set.up ->
          assertPets()
          set.down ->
            assertNoPets()
            set.down ->
              assertNoPets()
              set.up ->
                assertPets()
                testNewMigrations()
                done()

testNewMigrations = ->
  migrate "add dogs", ((next) ->
    db.pets.push name: "simon"
    db.pets.push name: "suki"
    next()
  ), (next) ->
    db.pets.pop()
    db.pets.pop()
    next()

  set.up ->
    assertPets.withDogs()
    set.up ->
      assertPets.withDogs()
      set.down ->
        assertNoPets()
        testMigrationEvents()

testMigrationEvents = ->
  migrate "adjust emails", ((next) ->
    db.pets.forEach (pet) ->
      pet.email = pet.email.replace("learnboost.com", "lb.com")  if pet.email

    next()
  ), (next) ->
    db.pets.forEach (pet) ->
      pet.email = pet.email.replace("lb.com", "learnboost.com")  if pet.email

    next()

  migrations = []
  completed = 0
  expectedMigrations = ["add guy ferrets", "add girl ferrets", "add emails", "add dogs", "adjust emails"]
  set.on "migration", (migration, direction) ->
    migrations.push migration.title
    direction.should.be.a "string"

  set.on "complete", ->
    ++completed

  set.up ->
    db.pets[0].email.should.equal "tobi@lb.com"
    migrations.should.eql expectedMigrations
    completed.should.equal 1
    migrations = []
    set.down ->
      migrations.should.eql expectedMigrations.reverse()
      completed.should.equal 2
      assertNoPets()
      testNamedMigrations()

testNamedMigrations = ->
  assertNoPets()
  set.up (->
    assertFirstMigration()
    set.up (->
      assertSecondMigration()
      set.down (->
        assertFirstMigration()
        set.up (->
          assertSecondMigration()
          set.down (->
            set.pos.should.equal 1
          ), "add girl ferrets"
        ), "add girl ferrets"
      ), "add girl ferrets"
    ), "add girl ferrets"
  ), "add guy ferrets"

# helpers
assertNoPets = ->
  db.pets.should.be.empty
  set.pos.should.equal 0

assertPets = ->
  db.pets.should.have.length 3
  db.pets[0].name.should.equal "tobi"
  db.pets[0].email.should.equal "tobi@learnboost.com"
  set.pos.should.equal 3

assertFirstMigration = ->
  db.pets.should.have.length 2
  db.pets[0].name.should.equal "tobi"
  db.pets[1].name.should.equal "loki"
  set.pos.should.equal 1

assertSecondMigration = ->
  db.pets.should.have.length 3
  db.pets[0].name.should.equal "tobi"
  db.pets[1].name.should.equal "loki"
  db.pets[2].name.should.equal "jane"
  set.pos.should.equal 2

assertPets.withDogs = ->
  db.pets.should.have.length 5
  db.pets[0].name.should.equal "tobi"
  db.pets[0].email.should.equal "tobi@learnboost.com"
  db.pets[4].name.should.equal "suki"