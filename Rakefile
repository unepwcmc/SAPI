#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require 'jslint/tasks' if Rails.env.development?
require 'sitemap_generator/tasks'

Rails.application.load_tasks
