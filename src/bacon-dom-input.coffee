module.exports = ($) ->
  nonEmpty = (x) ->
    x.length > 0

  assertArrayOrJQC = (x) ->
    unless typeof x is 'object' or x instanceof Array
      throw new Error('Value must be either an object or an Array of objects which conform to a minimal element query interface')

  asJQC = (x) ->
    $.Selector.toJQC(x)

  $.textField = {
    interval: 50
    take: 10
  }

  # Input element bindings
  $.textField =
    value: (element, options) ->
      defaultOpt = $.textField

      initValue = options.init
      get = -> element.val() || ""
      autofillPoller = ->
        Bacon.interval(options.interval || defaultOpt.interval).take(options.take || defaultOpt.take).map(get).filter(nonEmpty).take 1
      events = element.asEventStream("keyup input")
      .merge(element.asEventStream("cut paste").delay(1))
      .merge(autofillPoller())

      Bacon.Binding {
        initValue,
        get,
        events,
        set: (value) -> element.val(value)
      }

  $.checkBox =
    value: (element, options) ->
     initValue = options.init
     Bacon.Binding {
       initValue,
       get: -> element.prop("checked")||false,
       events: element.asEventStream("change"),
       set: (value) -> element.prop "checked", value
     }

    groupValue: (checkBoxes, options) ->
      initValue = options.init
      assertArrayOrJQC(checkBoxes)
      checkBoxes = asJQC(checkBoxes)
      Bacon.Binding {
        initValue,
        get: ->
          checkBoxes.filter(":checked").map((i, elem) ->
            $.Selector(elem).val()).toArray()
        events: checkBoxes.asEventStream("change"),
        set: (value) ->
          checkBoxes.each (i, elem) ->
            $.Selector(elem).prop "checked", $.indexOf(value, $.Selector(elem).val()) >= 0
      }

  $.select =
    value: (element, options) ->
      initValue = options.init
      Bacon.Binding {
        initValue,
        get: -> element.val(),
        events: element.asEventStream("change"),
        set: (value) -> element.val value
      }

  $.radioGroup =
      value: (radios, options) ->
        initValue = options.init
        assertArrayOrJQC(radios)
        radios = asJQC(radios)
        Bacon.Binding {
          initValue,
          get: -> radios.filter(":checked").first().val(),
          events: radios.asEventStream("change"),
          set: (value) ->
            radios.each (i, elem) ->
              $.Selector(elem).prop "checked", elem.value is value
        }

      intValue: (radios, options) ->
        initValue = options.init
        radioGroupValue = $.radioGroupValue(radios)
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

