define [
  'backbone'
  'underscore'
  'text!templates/cidr.html',
], (Bacbone, _, tpl) ->

  class CidrView extends Backbone.View
    bpm: 60
    events:
      'click .play': 'play'

    initialize: (options) ->
      @address = options.address
      @netmask = options.netmask
      @listenTo @address, 'change', @changed
      @listenTo @netmask, 'change', @changed
      @audioContext = new AudioContext()

    render: ->
      @$el.html _.template(tpl, {address: @address, netmask: @netmask})

    play: (e)->
      e.preventDefault()
      address = null
      if $(e.target).hasClass('play-address')
        address = @address
      if $(e.target).hasClass('play-netmask')
        address = @netmask
      if $(e.target).hasClass('play-network')
        address = @address.network(@netmask.toPrefix())
      if $(e.target).hasClass('play-broadcast')
        address = @address.broadcast(@netmask.toPrefix())
      binary = address.toString(2, separator: '', padding: 8)
      console.log binary

      currentTime = @audioContext.currentTime
      _(binary.split('')).each (char, i) =>
        start = currentTime + 60/@bpm/32*i*4
        stop = start + 0.1
        if char == '1'
          osc = @audioContext.createOscillator()
          osc.connect @audioContext.destination
          osc.frequency.value = 880
          osc.start(start)
          osc.stop(stop)
        if i % 8 == 0
          osc = @audioContext.createOscillator()
          osc.connect @audioContext.destination
          osc.frequency.value = 440
          osc.start(start)
          osc.stop(stop)

    changed: (cidr)->
      @render()
