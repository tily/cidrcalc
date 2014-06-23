define [
  'backbone'
], (Backbone)->
  class IpAddress extends Backbone.Model
    defaults:
      integer: 0

    fromInteger: (integer)->
      new IpAddress(integer: integer)
  
    fromString: (string)->
      octets = string.split('.')
      binary = octets.map (octet)=>
        @zeroPadding parseInt(octet).toString(2), 8
      .join('')
      new IpAddress(integer: parseInt(binary, 2))
  
    fromPrefix: (prefix)->
      binary = ''
      for i in [1..32]
        binary += if prefix >= i then '1' else '0'
      new IpAddress(integer: parseInt(binary, 2))
  
    toString: (radix, options)->
      options ||= {}
      console.log 'sep before', options
      if options.separator == ''
        options.separator = ''
      else
        options.separator = options.separator || '.'
      console.log 'sep', options
      binary = @zeroPadding @get('integer').toString(2), 32
      integers = []
      for i in [0..3]
        integers.push parseInt binary.slice(i*8, i*8+8), 2
      integers.map (integer)=>
        string = integer.toString(radix)
        string = @zeroPadding string, options.padding if options.padding
        string = options.prefix + string if options.prefix
        string
      .join(options.separator)
  
    toPrefix: ()->
      binary = @zeroPadding @get('integer').toString(2), 32
      binary.split('1').length - 1 

    zeroPadding: (number, length)->
      (Array(length).join('0') + number).slice(-length)

    network: (prefix)->
      netmask = @fromPrefix(prefix).get('integer')
      integer = (@get('integer') & netmask)>>>0
      new IpAddress(integer: integer)

    broadcast: (prefix)->
      netmask = @fromPrefix(prefix).get('integer')
      integer = (@get('integer') | ~netmask)>>>0
      new IpAddress(integer: integer)
