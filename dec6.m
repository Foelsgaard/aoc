#! /usr/bin/octave -qf

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};

## First part
coords = csvread(input);
xs = coords(:, 1);
ys = coords(:, 2);

x_span = min(xs):max(xs);
y_span = min(ys):max(ys);

dist_x = abs(xs .- x_span);
dist_y = abs(ys .- y_span);

dist = dist_x .+ permute(dist_y, [1, 3, 2]);

[min_dist, ix] = min(dist, [], [1]);

ix(sum(min_dist == dist) > 1) = NaN;
ix = permute(ix, [2, 3, 1]);
finite_ix = setdiff(ix, [ix(1,:) ix(end, :) ix(:, 1)' ix(:, end)']);
largest_area = max(sum(finite_ix == ix(1:end), 2));

printf("The largest finite area by Voronoi decomposition is %d\n", largest_area);

## Second part
closest_area = sum((sum(dist) < 10000)(1:end));
printf("The size of the area containing all locations within 10000 of every point is %d\n", closest_area);
