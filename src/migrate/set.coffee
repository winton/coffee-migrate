for key, value of require('./common')
  eval("var #{key} = value;")

module.exports = Set = (migrate_path) ->
  @migrations = []
  @path       = migrate_path
  @pos        = 0

  if fs.existsSync(setup = "#{path.dirname(@path)}/setup.coffee")
    setup = require setup
    setup @

Set::__proto__ = EventEmitter::

positionOfMigration = (migrations, filename) ->
  i = 0

  while i < migrations.length
    return i  if migrations[i].title is filename
    ++i

  -1

Set::save = (fn) ->
  self = this
  json = JSON.stringify(this)

  fs.writeFile @path, json, (err) ->
    self.emit "save"
    fn and fn(err)

Set::load = (fn) ->
  @emit "load"

  fs.readFile @path, "utf8", (err, json) ->
    return fn(err)  if err
    try
      fn null, JSON.parse(json)
    catch err
      fn err

Set::down = (fn, migrationName) ->
  @migrate "down", fn, migrationName

Set::up = (fn, migrationName) ->
  @migrate "up", fn, migrationName

Set::migrate = (direction, fn, migrationName) ->
  self = this
  fn   = fn or ->

  @load (err, obj) ->
    if err
      return fn(err)  unless "ENOENT" is err.code
    else
      self.pos = obj.pos

    self._migrate direction, fn, migrationName

Set::_migrate = (direction, fn, migrationName) ->
  next = (err, migration) ->
    
    # error from previous migration
    return fn(err)  if err
    
    # done
    unless migration
      self.emit "complete"
      self.save fn
      return

    self.emit "migration", migration, direction
    
    migration[direction] (err) ->
      next err, migrations.shift()

  self         = this
  migrations   = undefined
  migrationPos = undefined

  unless migrationName
    migrationPos = (if direction is "up" then @migrations.length else 0)
  
  else if (migrationPos = positionOfMigration(@migrations, migrationName)) is -1
    console.error "Could not find migration: " + migrationName
    process.exit 1
  
  switch direction
    when "up"
      migrations = @migrations.slice(@pos, migrationPos + 1)
      @pos += migrations.length
    when "down"
      migrations = @migrations.slice(migrationPos, @pos).reverse()
      @pos -= migrations.length
  
  next null, migrations.shift()