$(document.body).on 'click', '.togglers a', ->
  $(@).closest('.openable').toggleClass 'open'
  false

