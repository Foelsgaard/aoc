#! /usr/bin/octave -qf

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};

fid = fopen(input);
regex = fgetl(fid);
fclose(fid);

function [map offset regex ix x] = travel(map, offset, regex, ix, x)
  x1 = x;

  do
    c = regex(ix);

    dir = index("NESW", c);

    if dir
      map(x(1) + offset(1), x(2) + offset(2), dir) = 1;
      x += [-1 0; 0 1; 1 0; 0 -1](dir, :);

      if x(1) + offset(1) < 1
        offset(1) += 1;
        map = prepad(map, rows(map) + 1, 0, 1);
      endif

      if x(2) + offset(2) < 1
        offset(2) += 1;
        map = prepad(map, columns(map) + 1, 0, 2);
      endif

      map(x(1) + offset(1), x(2) + offset(2), [3 4 1 2](dir)) = 1;
    endif

    if c == '|'
      x = x1;
    elseif c == '('
      [map offset regex ix x] = travel(map, offset, regex, ix + 1, x);
    endif

    ix += 1;
  until c == ')' || c == '$'
  ix -= 1;
endfunction

function print_map(map, offset)

  printed_map = zeros(size(map)(1:2) * 2 + 1);
  printed_map(1:end, 1:end) = '#';

  for y = 1:rows(map)
    for x = 1:columns(map)
      py = y * 2;
      px = x * 2;
      printed_map(py, px) = '.';
      if map(y, x, 1)
        printed_map(py - 1, px) = '-';
      endif
      if map(y, x, 2)
        printed_map(py, px + 1) = '|';
      endif
      if map(y, x, 3)
        printed_map(py + 1, px) = '-';
      endif
      if map(y, x, 4)
        printed_map(py, px - 1) = '|';
      endif
    endfor
  endfor

  printed_map(offset(1) * 2, offset(2) * 2) = 'X';

  for r = 1:rows(printed_map)
    printf("%s\n", printed_map(r, :));
  endfor
endfunction

[map offset] = travel([], [1 1], regex, 1, [0 0]);
print_map(map, offset);


visited = false(size(map)(1:2));
distance = zeros(size(map)(1:2));

next = [offset];
i = 1;
do
  x = next(i, :);
  visited(x(1), x(2)) = true;
  neighbors = x + [-1 0; 0 1; 1 0; 0 -1](find(map(x(1), x(2), :)), :);

  j = 1;
  while j <= rows(neighbors)
    nx = neighbors(j, :);
    if ~visited(nx(1), nx(2))
      distance(nx(1), nx(2)) = distance(x(1), x(2)) + 1;
      next = [next; nx];
    endif
    j += 1;
  endwhile

  i += 1;
until i > rows(next)

printf("There is a distance of %d to the room furthest from the origin\n", max(distance(:)));
printf("There are %d rooms with a distance of a least 1000 from the origin\n", sum(distance(:) >= 1000));
