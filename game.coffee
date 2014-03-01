canvas = null
ctx    = null

frame = 0

canvas_width  = 640
canvas_height = 480

keys_down = {}

draw_scenery = ->
  ctx.fillStyle = 'black'
  ctx.fillRect 0, 0, canvas_width, canvas_height
  null

$(document).ready () ->

  canvas = $('#canvas')[0]
  ctx = canvas.getContext '2d'

  $(document).keydown (evt) ->
    keys_down[evt.which] = true
    null

  $(document).keyup (evt) ->
    delete keys_down[evt.which]
    null

  window.requestAnimFrame = (->
    window.requestAnimationFrame       or
    window.webkitRequestAnimationFrame or
    window.mozRequestAnimationFrame    or
    window.oRequestAnimationFrame      or
    window.msRequestAnimationFrame     or
    (callback) ->
      window.setTimeout callback, 1000 / 60
  )()

  (animloop = ->
    requestAnimFrame animloop
    if $('#running')[0].checked
      frame++
      draw_scenery()
      $('#debug')[0].innerHTML = "Frame #{frame}"
    null
  )()
