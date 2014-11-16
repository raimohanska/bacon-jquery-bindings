module.exports = ($) ->

  # Effects (jQuery compatible)
  effectNames = [
    "animate", "show", "hide", "toggle",
    "fadeIn", "fadeOut", "fadeTo", "fadeToggle",
    "slideDown", "slideUp", "slideToggle" ]

  effects = {}

  for e in effectNames
    do (e) ->
      effects[e + 'E'] = (args...) ->
        Bacon.fromPromise @[e](args...).promise()

  $.Extender.extend effects
  $