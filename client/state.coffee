$ = require "jquery"
localStorage["footer"] ?= "Hmmm..."

module.exports =
    populate: ({$nav,$status,$content,$footer}) ->
        $footer.append $("<p>").text localStorage["footer"] 
