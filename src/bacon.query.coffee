init = (Bacon, BaconModel, $) ->
  $ = $ || {}
  nonEmpty = (x) -> x.length > 0

  assertArrayOrQueryObject = (x) ->
    unless typeof x is 'object' or x instanceof Array
      throw new Error('Value must be either an object or an Array of objects which conform to a minimal element query interface')

  asQueryObject = (x) ->
    Bacon.$.Selector.toQueryObj(x)

  altIndxOf = (xs, x) ->
    for y, i in xs
      return i if x == y
    -1

  indxOf = (xs, x) -> xs.indexOf(x)

  Bacon.$.indexOf = if Array::indexOf then indxOf else altIndxOf

  Bacon.$.Model = Bacon.Model

  Bacon.$.Selector = $
  Bacon.$.Request = $
  Bacon.$.Promise = $
  Bacon.$.Extender = $.fn

  # Input element bindings
  Bacon.$.textFieldValue = (element, options) ->
    initValue = options.init
    get = -> element.val() || ""
    autofillPoller = ->
      Bacon.interval(options.interval || 50).take(options.take || 10).map(get).filter(nonEmpty).take 1
    events = element.asEventStream("keyup input")
      .merge(element.asEventStream("cut paste").delay(1))
      .merge(autofillPoller())

    Bacon.Binding {
      initValue,
      get,
      events,
      set: (value) -> element.val(value)
    }
  Bacon.$.checkBoxValue = (element, options) ->
    initValue = options.init
    Bacon.Binding {
      initValue,
      get: -> element.prop("checked")||false,
      events: element.asEventStream("change"),
      set: (value) -> element.prop "checked", value
    }

  Bacon.$.selectValue = (element, options) ->
    initValue = options.init
    Bacon.Binding {
      initValue,
      get: -> element.val(),
      events: element.asEventStream("change"),
      set: (value) -> element.val value
    }

  Bacon.$.radioGroupValue = (radios, options) ->
    initValue = options.init
    assertArrayOrQueryObject(radios)
    radios = Bacon.$.asQueryObject(radios)
    Bacon.Binding {
      initValue,
      get: -> radios.filter(":checked").first().val(),
      events: radios.asEventStream("change"),
      set: (value) ->
        radios.each (i, elem) ->
          Bacon.$.Selector(elem).prop "checked", elem.value is value
    }

  Bacon.$.intRadioGroupValue = (radios, options) ->
    initValue = options.init
    radioGroupValue = Bacon.$.radioGroupValue(radios)
    Bacon.Binding {
      initValue,
      get: ->
        value = radioGroupValue.get()
        if value?
          parseInt(value)
        else
          value
      events: radioGroupValue.syncEvents()
      set: (value) ->
        strValue = if value?
            Number(value).toString()
          else
            value
        radioGroupValue.set strValue
    }

  Bacon.$.checkBoxGroupValue = (checkBoxes, options) ->
    initValue = options.init
    assertArrayOrQueryObject(checkBoxes)
    checkBoxes = asQueryObject(checkBoxes)
    Bacon.Binding {
      initValue,
      get: ->
        checkBoxes.filter(":checked").map((i, elem) -> Bacon.$.Selector(elem).val()).toArray()
      events: checkBoxes.asEventStream("change"),
      set: (value) ->
        checkBoxes.each (i, elem) ->
          $(elem).prop "checked", Bacon.$.indexOf(value, Bacon.$.Selector(elem).val()) >= 0
    }

  # AJAX
  Bacon.$.ajax = (params, abort) ->
    Bacon.fromPromise Bacon.$.Request.ajax(params), abort

  Bacon.$.ajaxGet = (url, data, dataType, abort) ->
    Bacon.$.ajax({url, dataType, data}, abort)

  Bacon.$.ajaxGetJSON = (url, data, abort) ->
    Bacon.$.ajax({url, dataType: "json", data}, abort)

  Bacon.$.ajaxPost = (url, data, dataType, abort) ->
    Bacon.$.ajax({url, dataType, data, type: "POST"}, abort)

  Bacon.$.ajaxGetScript = (url, abort) ->
    Bacon.$.ajax({url, dataType: "script"}, abort)

  Bacon.$.lazyAjax = (params) ->
    Bacon.once(params).flatMap(Bacon.$.ajax)

  Bacon.Observable::ajax = ->
    @flatMapLatest Bacon.$.ajax

  # Deferred/Promise
  Bacon.Observable::toDeferred = ->
    value = undefined
    dfd = Bacon.$.Promise.deferred() || $.Deferred()
    @take(1).endOnError().subscribe((evt) ->
        if evt.hasValue()
          value = evt.value()
          dfd.notify(value)
        else if evt.isError()
          dfd.reject(evt.error)
        else if evt.isEnd()
          dfd.resolve(value)
        )
    dfd

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
      events[e + 'E'] = (args...) -> @asEventStream e, args...

  # Effects (jQuery compatible)

  effectNames = [
    "animate", "show", "hide", "toggle",
    "fadeIn", "fadeOut", "fadeTo", "fadeToggle",
    "slideDown", "slideUp", "slideToggle" ]

  effects = {}

  for e in effectNames
    do (e) ->
      effects[e + 'E'] = (args...) -> Bacon.fromPromise @[e](args...).promise()

  if Bacon.$.Extender
    Bacon.$.Extender.extend events
    Bacon.$.Extender.extend effects
    Bacon.$.Extender.asEventStream = Bacon.$.asEventStream

  # return the full API
  Bacon.$

if module?
  Bacon = require("baconjs")
  BaconModel = require("bacon.model")
  module.exports = init(Bacon, BaconModel, $)
else
  if typeof define == "function" and define.amd
    define ["bacon", "bacon.model", $], init
  else
    init(@Bacon, @BaconModel, @$)
