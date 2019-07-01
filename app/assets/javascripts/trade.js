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
//= require jquery
//= require jquery_ujs
//= require jquery-deparam
//= require jquery-ui
//= require jquery.mousewheel
//= require jquery.iframe-transport
//= require jquery.fileupload
//= require handlebars
//= require ember
//= require ember-data
//= require bootstrap-modal
//= require bootstrap-collapse
//= require bootstrap-alert
//= require date
//= require select2
//= require bootstrap-tooltip
//= require bootstrap-dropdown

//= require_self

//= require ./trade/store
//= require_tree ./trade/models
//= require ./trade/query_params
//= require_tree ./shared-mixins
//= require_tree ./trade/mixins
//= require_tree ./trade/controllers
//= require_tree ./trade/helpers
//= require_tree ./trade/views
//= require_tree ./trade/templates
//= require ./trade/router
//= require_tree ./trade/routes

var Trade = Ember.Application.create({
  customEvents: {
    blur: 'blur'
  }
});
