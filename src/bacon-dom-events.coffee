module.exports = ($) ->
  # DOM Events (jQuery compatible)
  eventNames = [
    "keydown", "keyup", "keypress",
    "click", "dblclick", "mousedown", "mouseup",
    "mouseenter", "mouseleave", "mousemove", "mouseout", "mouseover",
    "dragstart", "drag", "dragenter", "dragleave", "dragover", "drop", "dragend",
    "resize", "scroll", "select", "change",
    "submit",
    "blur", "focus", "focusin", "focusout",
    "load", "unload" ]
  events = {}

  for e in eventNames
    do (e) ->
      events[e + 'E'] = (args...) ->
        @asEventStream e, args...

  $.Extender.extend events
  $.Extender.asEventStream = Bacon.$.asEventStream
  $
