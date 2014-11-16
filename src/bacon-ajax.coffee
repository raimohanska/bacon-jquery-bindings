init ($) ->
  # AJAX
  $.ajax = (params, abort) ->
    Bacon.fromPromise $.Request.ajax(params), abort

  $.ajaxGet = (url, data, dataType, abort) ->
    $.ajax({url, dataType, data}, abort)

  $.ajaxGetJSON = (url, data, abort) ->
    $.ajax({url, dataType: "json", data}, abort)

  Bacon.$.ajaxPost = (url, data, dataType, abort) ->
    $.ajax({url, dataType, data, type: "POST"}, abort)

  $.ajaxGetScript = (url, abort) ->
    $.ajax({url, dataType: "script"}, abort)

  $.lazyAjax = (params) ->
    Bacon.once(params).flatMap(Bacon.$.ajax)

  Bacon.Observable::ajax = ->
    @flatMapLatest $.ajax