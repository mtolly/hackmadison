// Generated by CoffeeScript 1.7.1
(function() {
  var canvas, canvas_height, canvas_width, ch, char_to_square, click_square, ctx, draw_scenery, draw_square, find_pools, frames, grid, grid_left, grid_top, i, is_full, keys_down, load_file, load_puzzle, minutes, mouse_left, mouse_right, mouse_square, mouse_x, mouse_y, new_puzzle, pools, seconds, square_height, square_width, squares_high, squares_wide, _i, _j, _k, _l, _len, _len1, _m, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _results, _results1;

  canvas = null;

  ctx = null;

  frames = 0;

  seconds = 0;

  minutes = 0;

  canvas_width = 640;

  canvas_height = 480;

  keys_down = {};

  mouse_x = 0;

  mouse_y = 0;

  mouse_left = false;

  mouse_right = false;

  grid = [];

  square_width = 72;

  square_height = 72;

  grid_top = 15;

  grid_left = 15;

  squares_high = function() {
    return grid.length;
  };

  squares_wide = function() {
    if (grid.length === 0) {
      return 0;
    } else {
      return grid[0].length;
    }
  };

  pools = {};

  new_puzzle = function(height, width) {
    var c, r, row, _i, _j, _ref, _ref1;
    grid = [];
    for (r = _i = 0, _ref = height - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; r = 0 <= _ref ? ++_i : --_i) {
      row = [];
      for (c = _j = 0, _ref1 = width - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; c = 0 <= _ref1 ? ++_j : --_j) {
        row.push(null);
      }
      grid.push(row);
    }
    return null;
  };

  load_file = function(file) {
    var str;
    str = null;
    $.ajax({
      url: file,
      dataType: 'text',
      mimeType: 'text/plain',
      async: false,
      success: function(data) {
        str = data;
        return null;
      },
      error: function() {
        str = false;
        return null;
      }
    });
    return str;
  };

  char_to_square = {
    '#': true,
    '.': false,
    '-': null,
    '_': null
  };

  for (i = _i = 0; _i <= 9; i = ++_i) {
    char_to_square[i] = i;
  }

  _ref2 = (function() {
    _results = [];
    for (var _k = _ref = 'A'.charCodeAt(0), _ref1 = 'Z'.charCodeAt(0); _ref <= _ref1 ? _k <= _ref1 : _k >= _ref1; _ref <= _ref1 ? _k++ : _k--){ _results.push(_k); }
    return _results;
  }).apply(this);
  for (i = _j = 0, _len = _ref2.length; _j < _len; i = ++_j) {
    ch = _ref2[i];
    char_to_square[String.fromCharCode(ch)] = i + 10;
  }

  _ref5 = (function() {
    _results1 = [];
    for (var _m = _ref3 = 'a'.charCodeAt(0), _ref4 = 'z'.charCodeAt(0); _ref3 <= _ref4 ? _m <= _ref4 : _m >= _ref4; _ref3 <= _ref4 ? _m++ : _m--){ _results1.push(_m); }
    return _results1;
  }).apply(this);
  for (i = _l = 0, _len1 = _ref5.length; _l < _len1; i = ++_l) {
    ch = _ref5[i];
    char_to_square[String.fromCharCode(ch)] = i + 10;
  }

  load_puzzle = function(str) {
    var c, line, sq, sqs, _len2, _len3, _n, _o, _ref6, _ref7;
    grid = [];
    _ref6 = str.split('\n');
    for (_n = 0, _len2 = _ref6.length; _n < _len2; _n++) {
      line = _ref6[_n];
      sqs = [];
      _ref7 = line.split('');
      for (_o = 0, _len3 = _ref7.length; _o < _len3; _o++) {
        c = _ref7[_o];
        sq = char_to_square[c];
        if (sq !== void 0) {
          sqs.push(sq);
        }
      }
      if (sqs.length !== 0) {
        grid.push(sqs);
      }
    }
    return null;
  };

  is_full = function() {
    var row, val, _len2, _len3, _n, _o;
    for (_n = 0, _len2 = grid.length; _n < _len2; _n++) {
      row = grid[_n];
      for (_o = 0, _len3 = row.length; _o < _len3; _o++) {
        val = row[_o];
        if (val === null) {
          return false;
        }
      }
    }
    return true;
  };

  find_pools = function() {
    var c, cv, pool, r, rv, _len2, _len3, _n, _o, _p, _q, _ref6, _ref7, _ref8, _ref9;
    pools = {};
    for (r = _n = 0, _ref6 = squares_high() - 2; 0 <= _ref6 ? _n <= _ref6 : _n >= _ref6; r = 0 <= _ref6 ? ++_n : --_n) {
      for (c = _o = 0, _ref7 = squares_wide() - 2; 0 <= _ref7 ? _o <= _ref7 : _o >= _ref7; c = 0 <= _ref7 ? ++_o : --_o) {
        pool = true;
        _ref8 = [r, r + 1];
        for (_p = 0, _len2 = _ref8.length; _p < _len2; _p++) {
          rv = _ref8[_p];
          _ref9 = [c, c + 1];
          for (_q = 0, _len3 = _ref9.length; _q < _len3; _q++) {
            cv = _ref9[_q];
            if (grid[rv][cv] !== true) {
              pool = false;
            }
          }
        }
        if (pool) {
          pools["" + r + "," + c] = true;
        }
      }
    }
    return null;
  };

  mouse_square = function() {
    var c, r;
    c = Math.floor((mouse_x - grid_left) / square_width);
    r = Math.floor((mouse_y - grid_top) / square_height);
    if (((0 <= r && r < squares_wide())) && ((0 <= c && c < squares_high()))) {
      return [r, c];
    } else {
      return null;
    }
  };

  click_square = function(r, c) {
    if (typeof grid[r][c] === 'number') {
      return;
    }
    if (mouse_left && mouse_right) {
      grid[r][c] = null;
    } else if (mouse_left) {
      grid[r][c] = true;
    } else if (mouse_right) {
      grid[r][c] = false;
    }
    find_pools();
    return null;
  };

  draw_square = function(val, x, y) {
    var center_x, center_y;
    ctx.fillStyle = 'black';
    ctx.fillRect(x, y, square_width, square_height);
    switch (val) {
      case null:
        ctx.fillStyle = 'white';
        ctx.fillRect(x + 1, y + 1, square_width - 2, square_height - 2);
        break;
      case true:
        ctx.fillStyle = '#444';
        ctx.fillRect(x + 1, y + 1, square_width - 2, square_height - 2);
        break;
      case false:
        ctx.fillStyle = 'white';
        ctx.fillRect(x + 1, y + 1, square_width - 2, square_height - 2);
        center_x = x + square_width / 2;
        center_y = y + square_height / 2;
        ctx.fillStyle = 'black';
        ctx.fillRect(center_x - 4, center_y - 4, 8, 8);
        break;
      default:
        ctx.fillStyle = 'white';
        ctx.fillRect(x + 1, y + 1, square_width - 2, square_height - 2);
        ctx.fillStyle = 'black';
        if (val < 10) {
          ctx.font = "" + (square_height * 2 / 3) + "px Serif";
          ctx.fillText(val, x + (square_width * 2 / 7), y + (square_height * 3 / 4));
        } else {
          ctx.font = "" + (square_height * 3 / 5) + "px Serif";
          ctx.fillText(val, x + (square_width * 1 / 7), y + (square_height * 5 / 7));
        }
    }
    return null;
  };

  draw_scenery = function() {
    var c, r, row, val, _len2, _len3, _n, _o;
    ctx.fillStyle = 'gray';
    ctx.fillRect(0, 0, canvas_width, canvas_height);
    for (r = _n = 0, _len2 = grid.length; _n < _len2; r = ++_n) {
      row = grid[r];
      for (c = _o = 0, _len3 = row.length; _o < _len3; c = ++_o) {
        val = row[c];
        draw_square(val, grid_left + c * square_width, grid_top + r * square_height);
      }
    }
    return null;
  };

  $(document).ready(function() {
    var animloop, pad2, puz, puzzle_file;
    canvas = $('#canvas')[0];
    ctx = canvas.getContext('2d');
    $(document).keydown(function(evt) {
      keys_down[evt.which] = true;
      return null;
    });
    $(document).keyup(function(evt) {
      delete keys_down[evt.which];
      return null;
    });
    $(document).mousemove(function(evt) {
      var c, r, rect, sq;
      rect = canvas.getBoundingClientRect();
      mouse_x = evt.clientX - rect.left;
      mouse_y = evt.clientY - rect.top;
      if (sq = mouse_square()) {
        r = sq[0], c = sq[1];
        click_square(r, c);
      }
      return null;
    });
    $(document).mouseup(function(evt) {
      mouse_left = mouse_right = false;
      return null;
    });
    $(document).mousedown(function(evt) {
      var c, r, sq;
      switch (evt.which) {
        case 1:
          mouse_left = true;
          if (sq = mouse_square()) {
            r = sq[0], c = sq[1];
            click_square(r, c);
          }
          break;
        case 3:
          mouse_right = true;
          if (sq = mouse_square()) {
            r = sq[0], c = sq[1];
            click_square(r, c);
          }
      }
      return null;
    });
    window.requestAnimFrame = (function() {
      return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
        return window.setTimeout(callback, 1000 / 60);
      };
    })();
    puzzle_file = 'puzzles/1.txt';
    puz = load_file(puzzle_file);
    if (puz) {
      if (puz) {
        load_puzzle(puz);
      }
    } else {
      throw "Puzzle " + puzzle_file + " not found.";
    }
    pad2 = function(s) {
      return ('00' + s).slice(-2);
    };
    return (animloop = function() {
      var lines, s, _ref6;
      requestAnimFrame(animloop);
      if ($('#running')[0].checked) {
        frames++;
        if (frames === 60) {
          frames = 0;
          seconds++;
          if (seconds === 60) {
            seconds = 0;
            minutes++;
          }
        }
        draw_scenery();
        lines = [
          "Time: " + (pad2(minutes)) + ":" + (pad2(seconds)) + ";" + (pad2(frames)), "Mouse [" + mouse_left + ", " + mouse_right + "] at (" + mouse_x + ", " + mouse_y + ")", "Mouse square " + ((_ref6 = mouse_square()) != null ? _ref6.toString() : void 0), "Keys pressed: [" + (Object.keys(keys_down).toString()) + "]", "Pools: [" + (((function() {
            var _len2, _n, _ref7, _results2;
            _ref7 = Object.keys(pools);
            _results2 = [];
            for (_n = 0, _len2 = _ref7.length; _n < _len2; _n++) {
              s = _ref7[_n];
              _results2.push("(" + s + ")");
            }
            return _results2;
          })()).toString()) + "]"
        ];
        $('#debug')[0].innerHTML = lines.join('<br />');
      }
      return null;
    })();
  });

}).call(this);
