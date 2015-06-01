# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).ready ->
  $("a.load_more_articles")
    .on("ajax:success", (e, data, status, xhr) ->
      $("div#articles_container").append xhr.responseText
      new_URL_tag = $("dataset.load_more_articles_path")
      $(this).attr("href", new_URL_tag.data("load-more-path"))
      if not new_URL_tag.data("is-cut")
        $(this).addClass("hidden")
      
      new_URL_tag.removeClass("load_more_articles_path")
    ).on("ajax:error", (e, data, status, xhr) ->
      $("div#articles_container").append "Tapahtui virhe."
    )
    
