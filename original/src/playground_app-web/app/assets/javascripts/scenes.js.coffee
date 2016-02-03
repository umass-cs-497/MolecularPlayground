# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ -> $("#clear-model").click ->
  fieldSpan = $("#model-input")
  fieldSpan.html fieldSpan.html()
  false
$ -> $("#clear-script").click ->
  fieldSpan = $("#script-input")
  fieldSpan.html fieldSpan.html()
  false
