#! /usr/bin/octave -qf

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};

fid = fopen(input);
do
  vein_str = fgetl(fid);
  [x y1 y2] = sscanf(vein_str, "x=%d, y=%d..%d", "C");
  if isempty(x)
    [y x1 x2] = sscanf(vein_str, "y=%d, x=%d..%d", "C");
    map(y, x1:x2) = '#';
  else
    map(y1:y2, x) = '#';
  endif
until feof(fid)
fclose(fid);

map(map == 0) = '.';

global prev_down = false([size(map) 2]);
global prev_horz = false([size(map) 2]);

function [map, filled] = flow_down(map, x, y)
  global prev_down;
  if prev_down(y, x, 1)
    filled = prev_down(y, x, 2);
    return;
  endif

  y1 = y;
  y2 = y;
  while y2 < size(map)(1) && map(y2 + 1, x) != '#' && map(y2 + 1, x) != '~'
    y2 += 1;
  endwhile

  if y2 == size(map)(1)
    filled = false;
    map(y1:y2, x) = '|';
    return;
  endif

  while y2 >= y1
    if y == y2
    endif
    [map edge]= flow_horz(map, x, y2);
    if edge
      break
    endif
    y2 -= 1;
  endwhile

  filled = y2 < y1;

  prev_down(y, x, 1) = true;
  prev_down(y, x, 2) = filled;

  map(y1:y2, x) = '|';

endfunction

function [map edge] = flow_horz(map, x, y)
  global prev_horz;
  if prev_horz(y, x, 1)
    edge = prev_horz(y, x, 2);
    return;
  endif

  edge = false;
  x1 = x;
  x2 = x;

  edge1 = false;
  edge2 = false;

  while true
    if map(y, x1 - 1) == '#'
      break;
    endif

    if map(y + 1, x1) != '#' && map(y + 1, x1) != '~'
      [map filled] = flow_down(map, x1, y + 1);
      if ~filled
        edge1 = true;
        break;
      endif
    endif
    x1 -= 1;
  endwhile

  while true
    if map(y, x2 + 1) == '#'
      break;
    endif

    if map(y + 1, x2) != '#' && map(y + 1, x2) != '~'
      [map filled] = flow_down(map, x2, y + 1);
      if ~filled
        edge2 = true;
        break;
      endif
    endif
    x2 += 1;
  endwhile

  edge = edge1 || edge2;

  if edge
    map(y, x1:x2) = '|';
  else
    map(y, x1:x2) = '~';
  endif

  prev_horz(y, x, 1) = true;
  prev_horz(y, x, 2) = edge;

endfunction

flow_map = flow_down(map, 500, 1);

[ix] = find(map == '#');
[ys xs] = ind2sub(size(map), ix);
min_x = min(xs);

min_y = min(ys);
max_y = max(ys);

a = flow_map(min_y:max_y, :);
printf("The water can reach %d tiles\n", sum((a == '~' | a == '|')(:)));
printf("%d tiles of water are retained\n", sum((a == '~')(:)));
