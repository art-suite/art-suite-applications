{upperCamelCase} = Foundation = require "art.foundation"
Demos = require "./demos"

require "art.engine/full_screen_app"
.then ->
  query = Foundation.Browser.Parse.query()
  demo = Demos[upperCamelCase query.demo || ""]

  if demo
    demo.Main()
  else
    console.log "invalid option: ?demo=#{query.demo}" if query.demo
    console.log "Select demo with:"
    for demo in Demos.namespaces
      console.log "  ?demo=#{demo.name}"
