// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require underscore
//= require jquery
//= require jquery_ujs
//= require jquery-deparam
//= require jquery.cookie
//= require bootstrap-scrollspy
//= require handlebars
//= require ember
//= require ember-data
//= require ahoy
//
//= require_self
//
//= require ./species/store
//
//= require_tree ./species/helpers
//= require_tree ./species/models
//= require_tree ./shared-mixins
//= require_tree ./species/mixins
//= require_tree ./species/controllers
//= require_tree ./species/views
//= require_tree ./species/templates
//= require ./species/router
//= require_tree ./species/routes
//= require_tree ./shared

var Species = Ember.Application.create({
  rootElement: '#ember_app'
});
