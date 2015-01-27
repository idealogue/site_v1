$(document.body).on 'click', '.togglers a', ->
  $(@).closest('.openable').toggleClass 'open'
  false

class @Slider

  @sliders: {}

  constructor: (@$el) ->
    @_animating = false
    @$el
      .find '> .slider-item'
      .removeAttr 'style'
    @name = @$el.data 'slider'
    Slider.sliders[@name] = @
    @slides = $.makeArray(@$el.find('> .slider-item').map -> $(@).data 'slide')

    $(document.body).on 'click', "[data-prev-for='#{@name}']", (e) =>
      @goto(@prev(), $(e.currentTarget).data('scroll')) and false

    $(document.body).on 'click', "[data-next-for='#{@name}']", (e) =>
      @goto(@next(), $(e.currentTarget).data('scroll')) and false

    $(document.body).on 'click', "[data-slide-to^='#{@name}']", (e) =>
      $target = $(e.currentTarget)
      sliderSlides = $target.data('slide-to').split(' ')
      @gotoNested sliderSlides, $(e.currentTarget).data('scroll')
      false

    $(@).on 'slide:changed', @updateLabels
    $(@).trigger 'slide:changed', [@current()]

  updateLabels: =>
    $("[data-prev-for='#{@name}'] .label").text @prevLabel() if @prevLabel()
    $("[data-next-for='#{@name}'] .label").text @nextLabel() if @nextLabel()

  current: ->
    @$el.find('> .active').data 'slide'

  index: ->
    @$el.find("> [data-slide='#{@current()}']").index()

  next: ->
    @slides[(@index() + 1) % @slides.length]

  prev: ->
    [l, i] = [@slides.length, @index()]
    @slides[(l + i % l - 1) % l]

  prevLabel: ->
    @$el.find("> [data-slide='#{@prev()}']").data('label') or null

  nextLabel: ->
    @$el.find("> [data-slide='#{@next()}']").data('label') or null

  force: (slideName) ->
    @_animating = false
    $slide = @$el.find("> [data-slide='#{slideName}']")
    $current = @$el.find('> .active[data-slide]')
    $current
      .removeAttr 'style'
      .removeClass 'active'
    $slide
      .removeAttr 'style'
      .addClass 'active'
    $(@).trigger 'slide:changed', [$slide.data 'slide']

  gotoNested: (sliderSlides, scroll) ->
    for ss in sliderSlides[1..]
      [slider, slide] = ss.split(':')
      Slider.sliders[slider].force slide
    [slider, slide] = sliderSlides[0].split(':')
    @goto(slide, scroll)

  goto: (slideName, scroll) ->
    return if @_animating
    @_animating = true

    $slide = @$el.find("> [data-slide='#{slideName}']")
    $current = @$el.find('> .active[data-slide]')
    currentHeight = $current.height()

    afterScroll = =>
      $current
        .stop()
        .animate { opacity: 0 }, 150, =>
          $current
            .removeClass 'active'
            .removeAttr 'style'
          $slide
            .css opacity: 0
            .addClass 'active'
          $(@).trigger 'slide:changed', [$slide.data 'slide']
          height = $slide.height()
          @$el
            .css height: currentHeight
            .stop()
            .animate { height: height }, 150, =>
              @$el.removeAttr 'style'
              $slide
                .stop()
                .animate { opacity: 1 }, 150, =>
                  @_animating = false

    if typeof scroll is 'string'
      scrollTo = if scroll isnt ''
        scroll
      else
        "##{@name}"
      $('html, body')
        .stop()
        .animate { scrollTop: $(scrollTo).position().top }, 150, =>
          $current
            .stop()
            .animate { opacity: 0 }, 150, afterScroll
    else
      afterScroll()


$('.slider').each (i, el) -> new Slider $(el)

for name in ['index-team', 'index-projects']
  s = Slider.sliders[name]
  $(s).on 'slide:changed', (e, current) ->
    $("##{e.currentTarget.name.replace('index-', '')}").toggleClass 'slide--index', current is 'index'

for name, slider of Slider.sliders
  $(slider).trigger 'slide:changed', [slider.current()]

for name in ['team', 'projects']
  s = Slider.sliders[name]
  $(s).on 'slide:changed', (e, current) ->
    document.location.hash = "#/#{e.currentTarget.name}/#{current}"

hsh = location.hash.match /^#\/(projects|team)\/([a-z\-]+)$/
if hsh
  slide = $(".slider .slider [data-slide='#{hsh[2]}']").first()
  if slide
    sliders = $.makeArray slide.parents('[data-slider]').map -> $(@).data('slider')
    Slider.sliders[sliders[1]].gotoNested ["#{sliders[1]}:slides", "#{sliders[0]}:#{slide.data 'slide'}"], "##{sliders[0]}"

$('.slider-nav').removeAttr 'style'

