# Canvas stuff

canvas = null
ctx    = null

frames = 0
seconds = 0
minutes = 0

keys_down = {}

mouse_x = 0
mouse_y = 0
mouse_left = false
mouse_right = false

# Puzzle

grid = []
square_width = 40
square_height = 40
grid_top = 15
grid_left = 15

squares_high = -> grid.length
squares_wide = -> if grid.length == 0 then 0 else grid[0].length

pools = {}

colors = {}
current_color = 'black'

set_canvas = ->
  canvas.width = squares_wide() * square_width + 2 * grid_left
  canvas.height = squares_high() * square_height + 2 * grid_top

new_puzzle = (height, width) ->
  grid = []
  for r in [0 .. height - 1]
    row = []
    for c in [0 .. width - 1]
      row.push null
      colors["#{r},#{c}"] = 'black'
    grid.push row
  set_canvas()
  null

load_file = (file) ->
  str = null
  $.ajax
    url: file
    dataType: 'text'
    mimeType: 'text/plain'
    async: false
    success: (data) ->
      str = data
      null
    error: ->
      str = false
      null
  str

char_to_square =
  '#': true
  '.': false
  '-': null
  '_': null
for i in [0..9]
  char_to_square[i] = i
for ch, i in (['A'.charCodeAt(0) .. 'Z'.charCodeAt(0)])
  char_to_square[String.fromCharCode ch] = i + 10
for ch, i in (['a'.charCodeAt(0) .. 'z'.charCodeAt(0)])
  char_to_square[String.fromCharCode ch] = i + 10

load_puzzle = (str) ->
  grid = []
  for line in str.split '\n'
    sqs = []
    for c in line.split ''
      sq = char_to_square[c]
      sqs.push sq if sq isnt undefined
    grid.push sqs unless sqs.length is 0
  pools = {}
  colors = {}
  set_canvas()
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
    delete colors["#{r},#{c}"]
    grid[r][c] = null
    find_pools()
  else if mouse_left
    if current_color is 'black'
      delete colors["#{r},#{c}"]
    else
      colors["#{r},#{c}"] = current_color
    grid[r][c] = true
    find_pools()
  else if mouse_right
    if current_color is 'black'
      delete colors["#{r},#{c}"]
    else
      colors["#{r},#{c}"] = current_color
    grid[r][c] = false
    find_pools()
  null

draw_square = (val, x, y, color = 'black') ->
  ctx.fillStyle = 'black'
  ctx.fillRect x, y, square_width, square_height
  switch val
    when null
      ctx.fillStyle = 'white'
      ctx.fillRect x + 1, y + 1, square_width - 2, square_height - 2
    when true
      ctx.fillStyle = switch color
        when 'black' then '#444'
        when 'red' then '#622'
        when 'blue' then '#226'
        when 'green' then '#262'
      ctx.fillRect x + 1, y + 1, square_width - 2, square_height - 2
    when false
      ctx.fillStyle = 'white'
      ctx.fillRect x + 1, y + 1, square_width - 2, square_height - 2
      center_x = x + square_width / 2
      center_y = y + square_height / 2
      ctx.fillStyle = color
      ctx.fillRect center_x - 4, center_y - 4, 8, 8
    else
      ctx.fillStyle = 'white'
      ctx.fillRect x + 1, y + 1, square_width - 2, square_height - 2
      ctx.fillStyle = color
      if val < 10
        ctx.font = "#{square_height * 2 / 3}px Serif"
        ctx.fillText val, x + (square_width * 2 / 7), y + (square_height * 3 / 4)
      else
        ctx.font = "#{square_height * 3 / 5}px Serif"
        ctx.fillText val, x + (square_width * 1 / 8), y + (square_height * 5 / 7)
  null

draw_scenery = ->
  ctx.fillStyle = 'gray'
  ctx.fillRect 0, 0, canvas.width, canvas.height
  for row, r in grid
    for val, c in row
      draw_square(val, grid_left + c * square_width, grid_top + r * square_height, colors["#{r},#{c}"])
  null

$(document).ready () ->

  canvas = $('#canvas')[0]
  ctx = canvas.getContext '2d'

  $(document).keydown (evt) ->
    keys_down[evt.which] = true
    current_color =
      if      evt.which is 'Z'.charCodeAt 0 then 'red'
      else if evt.which is 'X'.charCodeAt 0 then 'blue'
      else if evt.which is 'C'.charCodeAt 0 then 'green'
      else                                       'black'
    if sq = mouse_square()
      [r, c] = sq
      click_square(r, c)
    null

  $(document).keyup (evt) ->
    delete keys_down[evt.which]
    null

  $(document).mousemove (evt) ->
    rect = canvas.getBoundingClientRect()
    mouse_x = evt.clientX - rect.left
    mouse_y = evt.clientY - rect.top
    if sq = mouse_square()
      [r, c] = sq
      click_square(r, c)
    null

  $(document).mouseup (evt) ->
    mouse_left = mouse_right = false
    null

  $(document).mousedown (evt) ->
    current_color =
      if      keys_down['Z'.charCodeAt 0] then 'red'
      else if keys_down['X'.charCodeAt 0] then 'blue'
      else if keys_down['C'.charCodeAt 0] then 'green'
      else                                     'black'
    switch evt.which
      when 1
        mouse_left = true
        if sq = mouse_square()
          [r, c] = sq
          click_square(r, c)
      when 3
        mouse_right = true
        if sq = mouse_square()
          [r, c] = sq
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

  puzzle_file = 'puzzles/2.txt'
  puz = load_file puzzle_file
  if puz
    load_puzzle puz if puz
  else
    throw "Puzzle #{puzzle_file} not found."
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
        , "Colors: [#{("#{k}: #{v}" for k, v of colors).toString()}]"
        , "Current color: #{current_color}"
        ]
      $('#debug')[0].innerHTML = lines.join '<br />'
    null
  )()

window.load_file = load_file
window.load_puzzle = load_puzzle
