$(document.body).on 'click', '.togglers a', ->
  $(@).closest('.openable').toggleClass 'open'
  false

class Slider

  constructor: (@$el) ->
    @_animating = false
    @$el
      .find '> .slider-item'
      .removeAttr 'style'
    @name = @$el.data 'slider'
    @slides = $.makeArray(@$el.find('> .slider-item').map -> $(@).data 'slide')
    $(document.body)
      .on 'click', "[data-prev-for='#{@name}']", (e) => @goto(@prev(), $(e.currentTarget).is('[data-scroll]')) and false
      .on 'click', "[data-next-for='#{@name}']", (e) => @goto(@next(), $(e.currentTarget).is('[data-scroll]')) and false

  current: ->
    @$el.find('> .active').data 'slide'

  index: ->
    @$el.find("> [data-slide='#{@current()}']").index()

  next: ->
    @slides[(@index() + 1) % @slides.length]

  prev: ->
    [l, i] = [@slides.length, @index()]
    @slides[(l + i % l - 1) % l]

  goto: (slideName, scroll = true) ->
    return if @_animating
    @_animating = true
    console.log slideName

    $slide = @$el.find("[data-slide='#{slideName}']")
    $current = @$el.find('.active[data-slide]')
    return if $slide.data('slide') is $current.data('slide')
    currentHeight = $current.height()

    afterScroll = =>
      $current
        .removeClass 'active'
        .removeAttr 'style'
      $slide
        .css opacity: 0
        .addClass 'active'
      height = $slide.height()
      @$el
        .css height: currentHeight
        .stop()
        .animate { height: height }, 200, =>
          @$el.removeAttr 'style'
          $slide
            .stop()
            .animate { opacity: 1 }, 200, =>
              @_animating = false

    if scroll
      $('html, body')
        .stop()
        .animate { scrollTop: $("##{@name}").position().top }, 200, =>
          $current
            .stop()
            .animate { opacity: 0 }, 200, afterScroll
    else
      afterScroll()


$('.slider').each (i, el) ->
  window.s = new Slider $(el)

