#! /usr/bin/octave -qf

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};

## First part
grid_serial = load(input);

xs = 1:300;
ys = 1:300;

power_levels = mod(floor((((xs + 10) .* ys' + grid_serial) .* (xs + 10)) / 100), 10) - 5;

[square_xx square_yy] = meshgrid(1:3, 1:3);
square = sub2ind([300 300], square_xx, square_yy) - sub2ind([300 300], 2, 2);

[xx yy] = meshgrid(2:299, 2:299);
squares = power_levels(permute(sub2ind([300 300], yy, xx), [3 4 1 2]) .+ square);
squares = ipermute(sum(sum(squares), 2), [3 4 1 2]);

[m ix] = max(squares(1:end));
[y x] = ind2sub(size(squares), ix);

printf("The maximum power level is %d and is found at the 3x3 square starting at (%d, %d)\n", m, x, y);

## Second part

max_power_level = -Inf;
max_power_level_size = 0;

for square_size=1:300
  printf("Checking squares of size %d\n", square_size);
  f = floor(square_size / 2);
  c = ceil(square_size / 2);
  [square_xx square_yy] = meshgrid(1:square_size, 1:square_size);
  square = sub2ind([300 300], square_xx, square_yy) - sub2ind([300 300], c, c);

  [xx yy] = meshgrid(c:300 - f, c:300 - f);
  squares = power_levels(permute(sub2ind([300 300], yy, xx), [3 4 1 2]) .+ square);
  squares = ipermute(sum(sum(squares, 1), 2), [3 4 1 2]);

  [m ix] = max(squares(1:end));

  if m > max_power_level
    max_power_level = m;
    max_power_level_size = square_size;
    [y x] = ind2sub(size(squares), ix);
  endif
endfor

printf("The maximum power level is %d and is found at the %dx%d square starting at (%d, %d)\n", max_power_level, max_power_level_size, max_power_level_size, x, y);
