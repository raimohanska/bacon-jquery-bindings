module.exports = ($) ->

  # Deferred/Promise
  Bacon.Observable::toDeferred = ->
    value = undefined
    dfd = $.Promise.deferred() || $.Deferred()
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