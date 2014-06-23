define [
  'backbone'
  'underscore'
  'text!templates/app.html',
  'app/models/ip_address_model',
  'app/views/cidr_view'
], (Bacbone, _, tpl, IpAddressModel, CidrView) ->

  class App extends Backbone.View
    el: "#total"
    # http://stackoverflow.com/questions/4460586/javascript-regular-expression-to-check-for-ip-addresses
    addressRegexp: /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/

    events:
      'keyup #address': 'changeAddress'
      'change #netmask': 'changeNetmask'
      'change #netmask-prefix': 'changeNetmask'

    initialize: (options) ->
      if match = location.hash.match(/#(.+)\/(.+)/)
        @address = (new IpAddressModel).fromString(match[1])
        @netmask = (new IpAddressModel).fromPrefix(parseInt match[2])
      else
        @address = new IpAddressModel(integer: 0)
        @netmask = new IpAddressModel(integer: 0)
      @listenTo @address, 'change', @changed
      @listenTo @netmask, 'change', @changed
      @cidrView = null

    changeAddress: (e)->
      val = @$(e.target).val()
      if val.match(@addressRegexp)
        @address.set 'integer', @address.fromString(val).get('integer')
        location.hash = @address.toString(10) + '/' + @netmask.toPrefix()

    changeNetmask: (e)->
      val = @$(e.target).val()
      @$('#netmask-prefix').val(val)
      @$('#netmask').val(val)
      @netmask.set 'integer', @address.fromPrefix(val).get('integer')

    render: ->
      @$el.html _.template(tpl, {address: @address, netmask: @netmask})
      @cidrView = new CidrView(address: @address, netmask: @netmask)
      @$('#cidr').append(@cidrView.render())

  appView = new App()
