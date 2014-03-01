# Canvas stuff

canvas = null
ctx    = null

frames = 0
seconds = 0
minutes = 0

canvas_width  = 640
canvas_height = 480

keys_down = {}

mouse_x = 0
mouse_y = 0
mouse_left = false
mouse_right = false

# Puzzle

grid = []
square_width = 72
square_height = 72
grid_top = 15
grid_left = 15

squares_high = -> grid.length
squares_wide = -> if grid.length == 0 then 0 else grid[0].length

pools = {}

new_puzzle = (height, width) ->
  grid = []
  for r in [0 .. height - 1]
    row = []
    for c in [0 .. width - 1]
      row.push null
    grid.push row
  null

is_full = ->
  for row in grid
    for val in row
      return false if val is null
  true

find_pools = ->
  pools = {}
  for r in [0 .. squares_high() - 2]
    for c in [0 .. squares_wide() - 2]
      pool = true
      for rv in [r, r + 1]
        for cv in [c, c + 1]
          pool = false unless grid[rv][cv] is true
      pools["#{r},#{c}"] = true if pool
  null

mouse_square = ->
  c = Math.floor (mouse_x - grid_left) / square_width
  r = Math.floor (mouse_y - grid_top) / square_height
  if (0 <= r < squares_wide()) and (0 <= c < squares_high())
    [r, c]
  else
    null

click_square = (r, c) ->
  return if typeof grid[r][c] is 'number'
  if mouse_left and mouse_right
    grid[r][c] = null
  else if mouse_left
    grid[r][c] = true
  else if mouse_right
    grid[r][c] = false
  find_pools()
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
    else
      ctx.fillStyle = 'white'
      ctx.fillRect x + 1, y + 1, square_width - 2, square_height - 2
      ctx.fillStyle = 'black'
      ctx.font = "#{square_height * 2 / 3}px Serif"
      ctx.fillText val, x + (square_width * 2 / 7), y + (square_height * 3 / 4)
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
    if [r, c] = mouse_square()
      click_square(r, c)
    null

  $(document).mouseup (evt) ->
    mouse_left = mouse_right = false
    null

  $(document).mousedown (evt) ->
    switch evt.which
      when 1
        mouse_left = true
        if [r, c] = mouse_square()
          click_square(r, c)
      when 3
        mouse_right = true
        if [r, c] = mouse_square()
          click_square(r, c)
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
  grid[1][2] = 4
  grid[4][0] = 5
  grid[4][2] = 2
  grid[4][4] = 3
  pad2 = (s) -> ('00' + s)[-2..-1]
  (animloop = ->
    requestAnimFrame animloop
    if $('#running')[0].checked
      frames++
      if frames is 60
        frames = 0
        seconds++
        if seconds is 60
          seconds = 0
          minutes++
      draw_scenery()
      lines =
        [ "Time: #{pad2(minutes)}:#{pad2(seconds)};#{pad2(frames)}"
        , "Mouse [#{mouse_left}, #{mouse_right}] at (#{mouse_x}, #{mouse_y})"
        , "Mouse square #{mouse_square() ?. toString()}"
        , "Keys pressed: [#{Object.keys(keys_down).toString()}]"
        , "Pools: [#{("(#{s})" for s in Object.keys(pools)).toString()}]"
        ]
      $('#debug')[0].innerHTML = lines.join '<br />'
    null
  )()
