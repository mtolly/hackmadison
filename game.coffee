# Canvas stuff

canvas = null
ctx    = null

frame = 0

canvas_width  = 640
canvas_height = 480

keys_down = {}

mouse_x = 0
mouse_y = 0
mouse_left = false
mouse_middle = false
mouse_right = false

# Puzzle

grid = []
square_width = 72
square_height = 72
grid_top = 15
grid_left = 15

squares_high = -> grid.length
squares_wide = -> if grid.length == 0 then 0 else grid[0].length

new_puzzle = (height, width) ->
  grid = []
  for r in [0 .. height - 1]
    row = []
    for c in [0 .. width - 1]
      row.push null
    grid.push row
  null

draw_square = (val, x, y) ->
  ctx.fillStyle = 'black'
  ctx.fillRect x, y, square_width, square_height
  switch val
    when null
      ctx.fillStyle = 'white'
      ctx.fillRect x + 1, y + 1, square_width - 2, square_height - 2
    when true
      ctx.fillStyle = '#444'
      ctx.fillRect x + 1, y + 1, square_width - 2, square_height - 2
    when false
      ctx.fillStyle = 'white'
      ctx.fillRect x + 1, y + 1, square_width - 2, square_height - 2
      center_x = x + square_width / 2
      center_y = y + square_height / 2
      ctx.fillStyle = 'black'
      ctx.fillRect center_x - 4, center_y - 4, 8, 8
    else null
  null

draw_scenery = ->
  ctx.fillStyle = 'gray'
  ctx.fillRect 0, 0, canvas_width, canvas_height
  for row, r in grid
    for val, c in row
      draw_square(val, grid_left + c * square_width, grid_top + r * square_height)
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

  $(document).mousemove (evt) ->
    rect = canvas.getBoundingClientRect()
    mouse_x = evt.clientX - rect.left
    mouse_y = evt.clientY - rect.top
    null

  $(document).mouseup (evt) ->
    switch evt.which
      when 1 then mouse_left = false
      when 2 then mouse_middle = false
      when 3 then mouse_right = false
    null

  $(document).mousedown (evt) ->
    switch evt.which
      when 1 then mouse_left = true
      when 2 then mouse_middle = true
      when 3 then mouse_right = true
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

  new_puzzle 5, 5
  grid[2][2] = true
  grid[3][3] = false
  (animloop = ->
    requestAnimFrame animloop
    if $('#running')[0].checked
      frame++
      draw_scenery()
      lines =
        [ "Frame #{frame}"
        , "Mouse #{mouse_left}, #{mouse_middle}, #{mouse_right} at (#{mouse_x}, #{mouse_y})"
        , "Keys at #{Object.keys(keys_down).toString()}"
        ]
      $('#debug')[0].innerHTML = lines.join '<br />'
    null
  )()
