// Fetched from channel: tags/v1.6.1, with url http://builds.emberjs.com/tags/v1.6.1/ember-template-compiler.js
// Fetched on: 2024-01-19T09:48:25Z
/*!
 * @overview  Ember - JavaScript Application Framework
 * @copyright Copyright 2011-2014 Tilde Inc. and contributors
 *            Portions Copyright 2006-2011 Strobe Inc.
 *            Portions Copyright 2008-2011 Apple Inc. All rights reserved.
 * @license   Licensed under MIT license
 *            See https://raw.github.com/emberjs/ember.js/master/LICENSE
 * @version   1.6.1
 */


(function() {
var Ember = { assert: function() {}, FEATURES: { isEnabled: function() {} } };
/**
@module ember
@submodule ember-handlebars-compiler
*/



// ES6Todo: you'll need to import debugger once debugger is es6'd.
if (typeof Ember.assert === 'undefined')   { Ember.assert = function(){}; };
if (typeof Ember.FEATURES === 'undefined') { Ember.FEATURES = { isEnabled: function(){} }; };

var objectCreate = Object.create || function(parent) {
  function F() {}
  F.prototype = parent;
  return new F();
};

// set up for circular references later
var View, Component;

// ES6Todo: when ember-debug is es6'ed import this.
// var emberAssert = Ember.assert;
var Handlebars = (Ember.imports && Ember.imports.Handlebars) || (this && this.Handlebars);
if (!Handlebars && typeof require === 'function') {
  Handlebars = require('handlebars');
}

Ember.assert("Ember Handlebars requires Handlebars version 1.0 or 1.1. Include " +
             "a SCRIPT tag in the HTML HEAD linking to the Handlebars file " +
             "before you link to Ember.", Handlebars);

Ember.assert("Ember Handlebars requires Handlebars version 1.0 or 1.1, " +
             "COMPILER_REVISION expected: 4, got: " +  Handlebars.COMPILER_REVISION +
             " - Please note: Builds of master may have other COMPILER_REVISION values.",
             Handlebars.COMPILER_REVISION === 4);

/**
  Prepares the Handlebars templating library for use inside Ember's view
  system.

  The `Ember.Handlebars` object is the standard Handlebars library, extended to
  use Ember's `get()` method instead of direct property access, which allows
  computed properties to be used inside templates.

  To create an `Ember.Handlebars` template, call `Ember.Handlebars.compile()`.
  This will return a function that can be used by `Ember.View` for rendering.

  @class Handlebars
  @namespace Ember
*/
var EmberHandlebars = Ember.Handlebars = objectCreate(Handlebars);

/**
  Register a bound helper or custom view helper.

  ## Simple bound helper example

  ```javascript
  Ember.Handlebars.helper('capitalize', function(value) {
    return value.toUpperCase();
  });
  ```

  The above bound helper can be used inside of templates as follows:

  ```handlebars
  {{capitalize name}}
  ```

  In this case, when the `name` property of the template's context changes,
  the rendered value of the helper will update to reflect this change.

  For more examples of bound helpers, see documentation for
  `Ember.Handlebars.registerBoundHelper`.

  ## Custom view helper example

  Assuming a view subclass named `App.CalendarView` were defined, a helper
  for rendering instances of this view could be registered as follows:

  ```javascript
  Ember.Handlebars.helper('calendar', App.CalendarView):
  ```

  The above bound helper can be used inside of templates as follows:

  ```handlebars
  {{calendar}}
  ```

  Which is functionally equivalent to:

  ```handlebars
  {{view App.CalendarView}}
  ```

  Options in the helper will be passed to the view in exactly the same
  manner as with the `view` helper.

  @method helper
  @for Ember.Handlebars
  @param {String} name
  @param {Function|Ember.View} function or view class constructor
  @param {String} dependentKeys*
*/
EmberHandlebars.helper = function(name, value) {
  if (!View) { View = requireModule('ember-views/views/view')['View']; } // ES6TODO: stupid circular dep
  if (!Component) { Component = requireModule('ember-views/views/component')['default']; } // ES6TODO: stupid circular dep

  Ember.assert("You tried to register a component named '" + name + "', but component names must include a '-'", !Component.detect(value) || name.match(/-/));

  if (View.detect(value)) {
    EmberHandlebars.registerHelper(name, EmberHandlebars.makeViewHelper(value));
  } else {
    EmberHandlebars.registerBoundHelper.apply(null, arguments);
  }
};

/**
  Returns a helper function that renders the provided ViewClass.

  Used internally by Ember.Handlebars.helper and other methods
  involving helper/component registration.

  @private
  @method makeViewHelper
  @for Ember.Handlebars
  @param {Function} ViewClass view class constructor
  @since 1.2.0
*/
EmberHandlebars.makeViewHelper = function(ViewClass) {
  return function(options) {
    Ember.assert("You can only pass attributes (such as name=value) not bare values to a helper for a View found in '" + ViewClass.toString() + "'", arguments.length < 2);
    return EmberHandlebars.helpers.view.call(this, ViewClass, options);
  };
};

/**
@class helpers
@namespace Ember.Handlebars
*/
EmberHandlebars.helpers = objectCreate(Handlebars.helpers);

/**
  Override the the opcode compiler and JavaScript compiler for Handlebars.

  @class Compiler
  @namespace Ember.Handlebars
  @private
  @constructor
*/
EmberHandlebars.Compiler = function() {};

// Handlebars.Compiler doesn't exist in runtime-only
if (Handlebars.Compiler) {
  EmberHandlebars.Compiler.prototype = objectCreate(Handlebars.Compiler.prototype);
}

EmberHandlebars.Compiler.prototype.compiler = EmberHandlebars.Compiler;

/**
  @class JavaScriptCompiler
  @namespace Ember.Handlebars
  @private
  @constructor
*/
EmberHandlebars.JavaScriptCompiler = function() {};

// Handlebars.JavaScriptCompiler doesn't exist in runtime-only
if (Handlebars.JavaScriptCompiler) {
  EmberHandlebars.JavaScriptCompiler.prototype = objectCreate(Handlebars.JavaScriptCompiler.prototype);
  EmberHandlebars.JavaScriptCompiler.prototype.compiler = EmberHandlebars.JavaScriptCompiler;
}


EmberHandlebars.JavaScriptCompiler.prototype.namespace = "Ember.Handlebars";

EmberHandlebars.JavaScriptCompiler.prototype.initializeBuffer = function() {
  return "''";
};

/**
  Override the default buffer for Ember Handlebars. By default, Handlebars
  creates an empty String at the beginning of each invocation and appends to
  it. Ember's Handlebars overrides this to append to a single shared buffer.

  @private
  @method appendToBuffer
  @param string {String}
*/
EmberHandlebars.JavaScriptCompiler.prototype.appendToBuffer = function(string) {
  return "data.buffer.push("+string+");";
};

// Hacks ahead:
// Handlebars presently has a bug where the `blockHelperMissing` hook
// doesn't get passed the name of the missing helper name, but rather
// gets passed the value of that missing helper evaluated on the current
// context, which is most likely `undefined` and totally useless.
//
// So we alter the compiled template function to pass the name of the helper
// instead, as expected.
//
// This can go away once the following is closed:
// https://github.com/wycats/handlebars.js/issues/634

var DOT_LOOKUP_REGEX = /helpers\.(.*?)\)/,
    BRACKET_STRING_LOOKUP_REGEX = /helpers\['(.*?)'/,
    INVOCATION_SPLITTING_REGEX = /(.*blockHelperMissing\.call\(.*)(stack[0-9]+)(,.*)/;

EmberHandlebars.JavaScriptCompiler.stringifyLastBlockHelperMissingInvocation = function(source) {
  var helperInvocation = source[source.length - 1],
      helperName = (DOT_LOOKUP_REGEX.exec(helperInvocation) || BRACKET_STRING_LOOKUP_REGEX.exec(helperInvocation))[1],
      matches = INVOCATION_SPLITTING_REGEX.exec(helperInvocation);

  source[source.length - 1] = matches[1] + "'" + helperName + "'" + matches[3];
};

var stringifyBlockHelperMissing = EmberHandlebars.JavaScriptCompiler.stringifyLastBlockHelperMissingInvocation;

var originalBlockValue = EmberHandlebars.JavaScriptCompiler.prototype.blockValue;
EmberHandlebars.JavaScriptCompiler.prototype.blockValue = function() {
  originalBlockValue.apply(this, arguments);
  stringifyBlockHelperMissing(this.source);
};

var originalAmbiguousBlockValue = EmberHandlebars.JavaScriptCompiler.prototype.ambiguousBlockValue;
EmberHandlebars.JavaScriptCompiler.prototype.ambiguousBlockValue = function() {
  originalAmbiguousBlockValue.apply(this, arguments);
  stringifyBlockHelperMissing(this.source);
};

/**
  Rewrite simple mustaches from `{{foo}}` to `{{bind "foo"}}`. This means that
  all simple mustaches in Ember's Handlebars will also set up an observer to
  keep the DOM up to date when the underlying property changes.

  @private
  @method mustache
  @for Ember.Handlebars.Compiler
  @param mustache
*/
EmberHandlebars.Compiler.prototype.mustache = function(mustache) {
  if (!(mustache.params.length || mustache.hash)) {
    var id = new Handlebars.AST.IdNode([{ part: '_triageMustache' }]);

    // Update the mustache node to include a hash value indicating whether the original node
    // was escaped. This will allow us to properly escape values when the underlying value
    // changes and we need to re-render the value.
    if (!mustache.escaped) {
      mustache.hash = mustache.hash || new Handlebars.AST.HashNode([]);
      mustache.hash.pairs.push(["unescaped", new Handlebars.AST.StringNode("true")]);
    }
    mustache = new Handlebars.AST.MustacheNode([id].concat([mustache.id]), mustache.hash, !mustache.escaped);
  }

  return Handlebars.Compiler.prototype.mustache.call(this, mustache);
};

/**
  Used for precompilation of Ember Handlebars templates. This will not be used
  during normal app execution.

  @method precompile
  @for Ember.Handlebars
  @static
  @param {String} string The template to precompile
  @param {Boolean} asObject optional parameter, defaulting to true, of whether or not the
                            compiled template should be returned as an Object or a String
*/
EmberHandlebars.precompile = function(string, asObject) {
  var ast = Handlebars.parse(string);

  var options = {
    knownHelpers: {
      action: true,
      unbound: true,
      'bind-attr': true,
      template: true,
      view: true,
      _triageMustache: true
    },
    data: true,
    stringParams: true
  };

  asObject = asObject === undefined ? true : asObject;

  var environment = new EmberHandlebars.Compiler().compile(ast, options);
  return new EmberHandlebars.JavaScriptCompiler().compile(environment, options, undefined, asObject);
};

// We don't support this for Handlebars runtime-only
if (Handlebars.compile) {
  /**
    The entry point for Ember Handlebars. This replaces the default
    `Handlebars.compile` and turns on template-local data and String
    parameters.

    @method compile
    @for Ember.Handlebars
    @static
    @param {String} string The template to compile
    @return {Function}
  */
  EmberHandlebars.compile = function(string) {
    var ast = Handlebars.parse(string);
    var options = { data: true, stringParams: true };
    var environment = new EmberHandlebars.Compiler().compile(ast, options);
    var templateSpec = new EmberHandlebars.JavaScriptCompiler().compile(environment, options, undefined, true);

    var template = EmberHandlebars.template(templateSpec);
    template.isMethod = false; //Make sure we don't wrap templates with ._super

    return template;
  };
}



exports.precompile = EmberHandlebars.precompile;
exports.EmberHandlebars = EmberHandlebars;
})();
