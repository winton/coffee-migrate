for key, value of require('./common')
  eval("var #{key} = value;")

module.exports = (title, up, down) ->
  @title = title
  @up    = up
  @down  = down
  @