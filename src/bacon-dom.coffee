init = (Bacon, BaconModel, JQC) ->
  JQC = JQC || {}

  altIndxOf = (xs, x) ->
    for y, i in xs
      return i if x == y
    -1

  indxOf = (xs, x) ->
    xs.indexOf x

  Bacon.$.indexOf = if Array::indexOf then indxOf else altIndxOf

  Bacon.$.Model = Bacon.Model

  Bacon.$.Selector = JQC
  Bacon.$.Request = JQC
  Bacon.$.Promise = JQC
  Bacon.$.Extender = JQC.fn

  Bacon.$.plugin = (names...) ->
    for name in names
      plugin = require "./bacon-#{name}"
      plugin Bacon.$

  # return the full API
  Bacon.$

if module?
  Bacon = require "baconjs"
  BaconModel = require "bacon.model"
  module.exports = init Bacon, BaconModel, $
else
  if typeof define == "function" and define.amd
    define ["bacon", "bacon.model", $], init
  else
    init(@Bacon, @BaconModel, @$)
