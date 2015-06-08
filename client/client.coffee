$     = require "jquery"
state = require "./state"

state.populate {
    $nav: $ "#nav"
    $status: $ "#status"
    $content: $ "#content"
    $footer: $ "#footer"
}
