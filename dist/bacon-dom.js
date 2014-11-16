(function() {
  init(function($) {
    $.ajax = function(params, abort) {
      return Bacon.fromPromise($.Request.ajax(params), abort);
    };
    $.ajaxGet = function(url, data, dataType, abort) {
      return $.ajax({
        url: url,
        dataType: dataType,
        data: data
      }, abort);
    };
    $.ajaxGetJSON = function(url, data, abort) {
      return $.ajax({
        url: url,
        dataType: "json",
        data: data
      }, abort);
    };
    Bacon.$.ajaxPost = function(url, data, dataType, abort) {
      return $.ajax({
        url: url,
        dataType: dataType,
        data: data,
        type: "POST"
      }, abort);
    };
    $.ajaxGetScript = function(url, abort) {
      return $.ajax({
        url: url,
        dataType: "script"
      }, abort);
    };
    $.lazyAjax = function(params) {
      return Bacon.once(params).flatMap(Bacon.$.ajax);
    };
    return Bacon.Observable.prototype.ajax = function() {
      return this.flatMapLatest($.ajax);
    };
  });

}).call(this);

(function() {
  var __slice = [].slice;

  module.exports = function($) {
    var e, effectNames, effects, _fn, _i, _len;
    effectNames = ["animate", "show", "hide", "toggle", "fadeIn", "fadeOut", "fadeTo", "fadeToggle", "slideDown", "slideUp", "slideToggle"];
    effects = {};
    _fn = function(e) {
      return effects[e + 'E'] = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return Bacon.fromPromise(this[e].apply(this, args).promise());
      };
    };
    for (_i = 0, _len = effectNames.length; _i < _len; _i++) {
      e = effectNames[_i];
      _fn(e);
    }
    $.Extender.extend(effects);
    return $;
  };

}).call(this);

(function() {
  var __slice = [].slice;

  module.exports = function($) {
    var e, eventNames, events, _fn, _i, _len;
    eventNames = ["keydown", "keyup", "keypress", "click", "dblclick", "mousedown", "mouseup", "mouseenter", "mouseleave", "mousemove", "mouseout", "mouseover", "dragstart", "drag", "dragenter", "dragleave", "dragover", "drop", "dragend", "resize", "scroll", "select", "change", "submit", "blur", "focus", "focusin", "focusout", "load", "unload"];
    events = {};
    _fn = function(e) {
      return events[e + 'E'] = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return this.asEventStream.apply(this, [e].concat(__slice.call(args)));
      };
    };
    for (_i = 0, _len = eventNames.length; _i < _len; _i++) {
      e = eventNames[_i];
      _fn(e);
    }
    $.Extender.extend(events);
    $.Extender.asEventStream = Bacon.$.asEventStream;
    return $;
  };

}).call(this);

(function() {
  module.exports = function($) {
    var asJQC, assertArrayOrJQC, nonEmpty;
    nonEmpty = function(x) {
      return x.length > 0;
    };
    assertArrayOrJQC = function(x) {
      if (!(typeof x === 'object' || x instanceof Array)) {
        throw new Error('Value must be either an object or an Array of objects which conform to a minimal element query interface');
      }
    };
    asJQC = function(x) {
      return $.Selector.toJQC(x);
    };
    $.textField = {
      interval: 50,
      take: 10
    };
    $.textField = {
      value: function(element, options) {
        var autofillPoller, defaultOpt, events, get, initValue;
        defaultOpt = $.textField;
        initValue = options.init;
        get = function() {
          return element.val() || "";
        };
        autofillPoller = function() {
          return Bacon.interval(options.interval || defaultOpt.interval).take(options.take || defaultOpt.take).map(get).filter(nonEmpty).take(1);
        };
        events = element.asEventStream("keyup input").merge(element.asEventStream("cut paste").delay(1)).merge(autofillPoller());
        return Bacon.Binding({
          initValue: initValue,
          get: get,
          events: events,
          set: function(value) {
            return element.val(value);
          }
        });
      }
    };
    $.checkBox = {
      value: function(element, options) {
        var initValue;
        initValue = options.init;
        return Bacon.Binding({
          initValue: initValue,
          get: function() {
            return element.prop("checked") || false;
          },
          events: element.asEventStream("change"),
          set: function(value) {
            return element.prop("checked", value);
          }
        });
      },
      groupValue: function(checkBoxes, options) {
        var initValue;
        initValue = options.init;
        assertArrayOrJQC(checkBoxes);
        checkBoxes = asJQC(checkBoxes);
        return Bacon.Binding({
          initValue: initValue,
          get: function() {
            return checkBoxes.filter(":checked").map(function(i, elem) {
              return $.Selector(elem).val();
            }).toArray();
          },
          events: checkBoxes.asEventStream("change"),
          set: function(value) {
            return checkBoxes.each(function(i, elem) {
              return $.Selector(elem).prop("checked", $.indexOf(value, $.Selector(elem).val()) >= 0);
            });
          }
        });
      }
    };
    $.select = {
      value: function(element, options) {
        var initValue;
        initValue = options.init;
        return Bacon.Binding({
          initValue: initValue,
          get: function() {
            return element.val();
          },
          events: element.asEventStream("change"),
          set: function(value) {
            return element.val(value);
          }
        });
      }
    };
    return $.radioGroup = {
      value: function(radios, options) {
        var initValue;
        initValue = options.init;
        assertArrayOrJQC(radios);
        radios = asJQC(radios);
        return Bacon.Binding({
          initValue: initValue,
          get: function() {
            return radios.filter(":checked").first().val();
          },
          events: radios.asEventStream("change"),
          set: function(value) {
            return radios.each(function(i, elem) {
              return $.Selector(elem).prop("checked", elem.value === value);
            });
          }
        });
      },
      intValue: function(radios, options) {
        var initValue, radioGroupValue;
        initValue = options.init;
        radioGroupValue = $.radioGroupValue(radios);
        return Bacon.Binding({
          initValue: initValue,
          get: function() {
            var value;
            value = radioGroupValue.get();
            if (value != null) {
              return parseInt(value);
            } else {
              return value;
            }
          },
          events: radioGroupValue.syncEvents(),
          set: function(value) {
            var strValue;
            strValue = value != null ? Number(value).toString() : value;
            return radioGroupValue.set(strValue);
          }
        });
      }
    };
  };

}).call(this);

(function() {
  var Bacon, BaconModel, init,
    __slice = [].slice;

  init = function(Bacon, BaconModel, JQC) {
    var altIndxOf, indxOf;
    JQC = JQC || {};
    altIndxOf = function(xs, x) {
      var i, y, _i, _len;
      for (i = _i = 0, _len = xs.length; _i < _len; i = ++_i) {
        y = xs[i];
        if (x === y) {
          return i;
        }
      }
      return -1;
    };
    indxOf = function(xs, x) {
      return xs.indexOf(x);
    };
    Bacon.$.indexOf = Array.prototype.indexOf ? indxOf : altIndxOf;
    Bacon.$.Model = Bacon.Model;
    Bacon.$.Selector = JQC;
    Bacon.$.Request = JQC;
    Bacon.$.Promise = JQC;
    Bacon.$.Extender = JQC.fn;
    Bacon.$.plugin = function() {
      var name, names, plugin, _i, _len, _results;
      names = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _results = [];
      for (_i = 0, _len = names.length; _i < _len; _i++) {
        name = names[_i];
        plugin = require("./bacon-" + name);
        _results.push(plugin(Bacon.$));
      }
      return _results;
    };
    return Bacon.$;
  };

  if (typeof module !== "undefined" && module !== null) {
    Bacon = require("baconjs");
    BaconModel = require("bacon.model");
    module.exports = init(Bacon, BaconModel, $);
  } else {
    if (typeof define === "function" && define.amd) {
      define(["bacon", "bacon.model", $], init);
    } else {
      init(this.Bacon, this.BaconModel, this.$);
    }
  }

}).call(this);

(function() {
  module.exports = function($) {
    return Bacon.Observable.prototype.toDeferred = function() {
      var dfd, value;
      value = void 0;
      dfd = $.Promise.deferred() || $.Deferred();
      this.take(1).endOnError().subscribe(function(evt) {
        if (evt.hasValue()) {
          value = evt.value();
          return dfd.notify(value);
        } else if (evt.isError()) {
          return dfd.reject(evt.error);
        } else if (evt.isEnd()) {
          return dfd.resolve(value);
        }
      });
      return dfd;
    };
  };

}).call(this);
