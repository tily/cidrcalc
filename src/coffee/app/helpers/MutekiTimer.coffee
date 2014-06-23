'use strict'

define [], ()->
  # Muteki Timer - A stable timer that run in the background
  
  setInterval   = window.setInterval
  clearInterval = window.clearInterval
  
  SOURCE = '''
  var t = 0;
  onmessage = function(e) {
      if (t) {
          t = clearInterval(t), 0;
      }
      if (typeof e.data === "number" && e.data > 0) {
          t = setInterval(function() {
              postMessage(0);
          }, e.data);
      }
  };
  '''
  TIMER_PATH = (window.URL ? window.webkitURL)?.createObjectURL(
      try new Blob([SOURCE], type:'text/javascript') catch e then null
  )
  
  
  class MutekiTimer
      constructor: ->
          if TIMER_PATH
              @timer = new Worker(TIMER_PATH)
          else
              @timer = 0
  
      setInterval: (func, interval=100)->
          if typeof @timer is 'number'
              @timer = setInterval func, interval
          else
              @timer.onmessage = func
              @timer.postMessage interval
  
      clearInterval: ->
          if typeof @timer is 'number'
              clearInterval @timer
          else
              @timer.postMessage 0
  
  tid  = +new Date()
  pool = {}
  _setInterval = (func, interval)->
      t = new MutekiTimer()
      t.setInterval func, interval
      pool[++tid] = t
      tid
  
  _clearInterval = (id)->
      pool[id]?.clearInterval()
      undefined
  
  MutekiTimer.use = =>
      window.setInterval   = _setInterval
      window.clearInterval = _clearInterval
  
  MutekiTimer.unuse = =>
      window.setInterval   = setInterval
      window.clearInterval = clearInterval
  
  MutekiTimer.isEnabled = ->
      !!TIMER_PATH
  
  console.log MutekiTimer
  #@MutekiTimer = MutekiTimer
  MutekiTimer
