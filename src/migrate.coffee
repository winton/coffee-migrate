for key, value of require('./migrate/common')
  eval("var #{key} = value;")

Migration = require("./migrate/migration")
Set       = require("./migrate/set")

module.exports = migrate = (title, up, down) ->
  
  # migration
  if ("string" is typeof title) and up and down
    migrate.set.migrations.push(new Migration(title, up, down))
  
  # specify migration file
  else if "string" is typeof title
    migrate.set = new Set(title)
  
  # no migration path
  else unless migrate.set
    throw new Error("must invoke migrate(path) before running migrations")
  
  # run migrations
  else
    migrate.set