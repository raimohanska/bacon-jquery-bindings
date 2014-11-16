# bacon.query

A JQuery compatible (JQC) data binding library for [Bacon.js](https://github.com/baconjs/bacon.js).

See fx [Ender.js](http://enderjs.com/#docs) `$._select` which you can use with [qwery](https://github.com/ded/qwery)

```js
$._select = mySelectorEngine
$('#foo .bar')
```

See [example](https://github.com/ded/qwery/blob/master/src/ender.js)

[Zepto.js](http://zeptojs.com/) is another powerful jQuery alternative...

This library adds stuff to `Bacon.$`. It is also called "Baquery" (pronounced like "bakery").

Includes

- Binding the state of HTML input elements to [`Bacon.Model`](https://github.com/baconjs/bacon.model) objects that extend
  the Bacon.js `Property` API by providing a bidirectional binding
- AJAX helpers. Wrap a JQC AJAX call into an EventStream using
  `Bacon.$.ajax("/get/stuff")`. Convert an `EventStream` of requests
into an `EventStream` of responses like `requests.ajax()`.
- FRP extensions to JQC API. Wrap JQC events easily into an `EventStream`, as
  in `$("body").clickE()`

This library is a replacement for [Bacon.UI](https://github.com/raimohanska/Bacon.UI.js).

It provides the same functionality, with the addition of two-way bound Models, model composition and lenses.

## Example Applications

There are example applications in the [examples](https://github.com/baconjs/bacon.query/tree/master/examples) directory, each with a README.md describing how they are started.

Each application does essentially the same thing and the code in the example applications is essentially just this:

```js
  // binding for "left" text field
  left = bjq.textFieldValue($("#left"))
  // binding for "right" text field
  right = bjq.textFieldValue($("#right"))
  // make a two-way binding between these two
  // values in the two fields will now stay in sync
  right.bind(left)
  // Make a one-way side effect: update label text on changes, uppercase
  right.map(".toUpperCase").changes().assign($("#output"), "text")
  // Add an input stream for resetting the value
  left.addSource($("#reset").asEventStream("click").map(""))
```

## API

The `bacon.query` API consists of methods for creating a `Model` representing the
state of a DOM element or a group of DOM elements. This API is published
as `Bacon.$`, and the same object is returned when using AMD or
CommonJS.

Note: The optional initiValue has now been replaced with an (optional) options hash.
Instead of `Bacon.$.textFieldValue(field, '')` use `Bacon.$.textFieldValue(field, {init: ''})`.
This is to allow for more flexibility down the line...

### Plugins


- `ajax`
- `dom-input`
- `effects`
- `events`
- `promise` (deferred)

Use `Bacon.$.plugin('dom-input', 'ajax')` to add the plugins you want to enable.

### DOM Input

`Bacon.$.addPlugin('dom-input')`

###Bacon.$.textFieldValue(field [, initValue])

Creates a `Model` for an
`<input type="text">` element, given as a JQC object. You can optionally supply an initial value.

###Bacon.$.checkBoxValue(field [, initValue])

Creates a `Model` for a
`<input type="checkbox">` element, given as a JQC object. The value is `true` if the checkbox is checked and
`false` otherwise.

###Bacon.$.selectValue(field [,initValue])

Creates a `Model` for a `<select>`
element, given as a JQC object. The value of the model corresponds to the `value` attribute of the selected `<option>` element.

###Bacon.$.radioGroupValue(fields, [,initValue])

Creates a `Model` for a
group of `<input type="radio">` elements, given as a JQC object/Array.
The value of the model corresponds to the `value` attribute
of the selected radio input element. Note that `value` is a string.

###Bacon.$.intRadioGroupValue(fields [, initValue])

Like `Bacon.$.radioGroupValue`, but for integer values. 

###Bacon.$.checkBoxGroupValue(fields, [,initValue])

Creates a `Model` for a group
of `<input type="checkbox">` elements, given as a JQC object/Array . The value of the model is an array of the `value` attributes of
the checked checkbox input elements. For instance, if you have checkboxes and 2
of these are checked, having values `a` and `b`, the value of the Model is
`["a", "b"]`.

TODO: add HTML/JS examples

## FRP extensions to JQC Events

BJQ adds methods to JQC, for wrapping events into an `EventStream`.

For example, to wrap click events on `<body>` into an `EventStream`, you
can

    var clicks = $("body").clickE()

Supported methods include the following:

- keydownE
- keyupE
- keypressE
- clickE
- dblclickE
- mousedownE
- mouseupE
- mouseenterE
- mouseleaveE
- mousemoveE
- mouseoutE
- mouseoverE
- dragstart
- drag
- dragenter
- dragleave
- dragover
- drop
- dragend
- resizeE
- scrollE
- selectE
- changeE
- submitE
- blurE
- focusE
- focusinE
- focusoutE
- loadE
- unloadE

## FRP extensions to JQC Effects

BJQ adds methods to JQC, for performing animations and wrapping the
result `Promise` into an `EventStream`. For example

    var fadeOut = $("#thing").fadeOutE("fast")

Supported methods include the following:

- animateE
- showE
- hideE
- toggleE
- fadeInE
- fadeOutE
- fadeToE
- fadeToggleE
- slideDownE
- slideUpE
- slideToggleE

## AJAX

BJQ provides helpers for JQC AJAX. All the methods return an
`EventStream` of AJAX results. AJAX errors are mapped into `Error`
events in the stream.

Aborted requests are not sent into the error stream. If you want to have a
stream that observes whether an AJAX request is running, use `Bacon.awaiting`.
For example:

    var searchParams = Bacon.once({ url: '/search', data: { query: 'apple' } })
    var ajaxRequest = searchParams.ajax()
    var requestRunning = searchParams.awaiting(ajaxRequest)
    requestRunning.assign($('#ajaxSpinner'), 'toggle')

### stream.ajax(fn)

Performs an AJAX request on each event of your stream, collating results in the result stream.

The source stream is expected to provide the parameters for the AJAX call.

    var usernameRequest = username.map(function(un) { return { type: "get", url: "/usernameavailable/" + un } })
    var usernameAvailable = usernameRequest.changes().ajax()

### Bacon.$.ajax(params)

Performs an AJAX request and returns the results in an EventStream.

    var results = Bacon.$.ajax("/get/results")

or

    var results = Bacon.$.ajax({ url: "/get/results"})

### Bacon.$.lazyAjax(params)

Like above, but performs the AJAX call lazily, i.e. not before it has a subscriber.

### Bacon.$.ajaxGet(url, data, dataType)

### Bacon.$.ajaxGetJSON(url, data)

### Bacon.$.ajaxPost(url, data, dataType)

### Bacon.$.ajaxGetScripts(url)

### stream.toDeferred()

Turns your Bacon Ajax stream back to $.Deferred. It's useful if you need to provide a solution for users who are not familiar with Bacon.

## Model API

All the BJQ methods, such as `textFieldValue` return a `Model` object, which is a Bacon.js `Property`,
but extends that API with [bacon.model](https://github.com/baconjs/bacon.model) methods

## Use with AMD / RequireJS

The [requirejs example-app](https://github.com/baconjs/bacon.query/tree/master/examples/requirejs) uses RequireJS, like this:

```js
require.config({
  paths: {
    "bacon.query": "../dist/bacon.query",
    "bacon": "components/bacon/dist/Bacon",
    "jquery": "components/jquery/jquery"
  }})
require(["bacon.query", "jquery"], function(bjq, $) {
  left = bjq.textFieldValue($("#left"))
  right = bjq.textFieldValue($("#right"))
  right.bind(left)
  right.assign($("#output"), "text")
})
```

Note: You can substitute jquery with Zepto or any other compatible library ;)

The prebuilt javascript file can be found in the `dist` directory, or [here](https://raw.github.com/baconjs/bacon.query/master/dist/Bacon.Query.Bindings.js).

The API can be accessed using `Bacon.$` or like in the above example.

## Use without AMD

The [plain example-app](https://github.com/baconjs/bacon.query/tree/master/examples/plain) uses RequireJS, like this:

So feel free to use plain old `<script>` tags to include Bacon, and JQC lib and BJQ.

The BJQ methods are exposed through `Bacon.$`, so you can call them as in `Bacon.$.textFieldValue(..)`.

The prebuilt javascript file can be found in the `dist` directory, or [here](https://raw.github.com/baconjs/bacon.query/master/dist/Bacon.Query.Bindings.js).

There's a [plain example-app](https://github.com/baconjs/bacon.query/tree/master/examples/plain) that uses script tags only.

## Use with Node / Browserify

BJQ is registered in the NPM repository as `bacon.query` and works fine with [node-browserify](https://github.com/substack/node-browserify).

See the [browserify example-app](https://github.com/baconjs/bacon.query/tree/master/examples/browserify) for an example.

## Use with Bower

Registered to the Bower registry as `bacon.query`. See the
Example Applications, for instance [requirejs example-app](https://github.com/baconjs/bacon.query/tree/master/examples/requirejs).

## Building

The `bacon.query` module is built using NPM and Grunt.

To build, use `npm install`.

Built javascript files are under the `dist` directory.

## Automatic tests

Use the `npm test` to run all tests.

Tests include mocha tests under the `test` directory, and mocha browser tests under the `browsertest`
directory. The test script uses [mocha-phantomjs](http://metaskills.net/mocha-phantomjs/) to run the browser tests headless.

The browser tests can also be run by opening the
`browsertest/runner.html` in the browser.

The tests are also run automatically on [Travis CI](https://travis-ci.org/). See build status below.

[![Build Status](https://travis-ci.org/baconjs/bacon.query.png)](https://travis-ci.org/baconjs/bacon.query)

## What next?

See [Issues](https://github.com/baconjs/bacon.query/issues).

If this seems like a good idea, please tell me so! If you'd like to
contribute, please do! Pull Requests, Issues etc appreciated. Star this project to let me know that you care.
