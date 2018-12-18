#! /usr/bin/octave -qf

args = argv();
if length(args) < 1 || length(args) > 2
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};
if length(args) == 2
  maxn = str2num(args{2});
else
  maxn = Inf;
endif


track = [];
fid = fopen(input);
do
  track(end+1,:) = fgetl(fid);
until feof(fid)
fclose(fid);

function b = is_cart(v)
  b = v == '>' | v == '<' | v == 'v' | v == '^';
  return;
endfunction

start_cart_ix = find(is_cart(track))';
carts = track(start_cart_ix);
track(track == '>' | track == '<') = '-';
track(track == 'v' | track == '^') = '|';


reflections = repmat(eye(2), [1 1 size(track)]);

reflections(1, 1, track == '/') = 0;
reflections(1, 2, track == '/') = -1;
reflections(2, 1, track == '/') = -1;
reflections(2, 2, track == '/') = 0;

reflections(1, 1, track == '\') = 0;
reflections(2, 1, track == '\') = 1;
reflections(1, 2, track == '\') = 1;
reflections(2, 2, track == '\') = 0;

intersection(:, :, 1) = [0 1; -1 0];
intersection(:, :, 2) = [1 0;  0 1];
intersection(:, :, 3) = [0 -1; 1 0];

intersections = find(track == '+');

line = repmat('-', 1, length(track));

dpos = zeros(2, length(carts));
dpos(1, carts == '>') = 1;
dpos(1, carts == '<') = -1;
dpos(2, carts == 'v') = 1;
dpos(2, carts == '^') = -1;

cart_ix = start_cart_ix;

track_with_carts = track;
track_with_carts(cart_ix(dpos(1, :) == 1)) = '>';
track_with_carts(cart_ix(dpos(1, :) == -1)) = '<';
track_with_carts(cart_ix(dpos(2, :) == 1)) = 'v';
track_with_carts(cart_ix(dpos(2, :) == -1)) = '^';

## for i = 1:size(track_with_carts)(1)
##   printf("%s\n", track_with_carts(i, :));
## endfor
## printf("%s\n", line);

first_crash = 0;

turns = zeros(size(start_cart_ix));
[ys xs] = ind2sub(size(track), start_cart_ix);
pos = [xs; ys];
n = 1;
do
  ## if mod(n, 100) == 0
  ##   printf("%d\n", n);
  ## endif
  for i = 1:length(cart_ix)
    dpos(:, i) = reflections(:, :, cart_ix(i)) * dpos(:, i);
    if track(cart_ix(i)) == '+'
      dpos(:, i) = intersection(:, :, turns(i) + 1) * dpos(:, i);
      turns(i) = mod(turns(i) + 1, 3);
    endif
  endfor

  [cart_ix, order] = sort(cart_ix);
  pos = pos(:, order);
  dpos = dpos(:, order);
  turns = turns(order);

  crashes = false(size(cart_ix));

  for i = 1:length(cart_ix)
    pos(:, i) += dpos(:, i);
    for j = i+1:length(cart_ix)
      if pos(:, i) == pos(:, j)
        crashes(i) = true;
        crashes(j) = true;
      endif
    endfor
  endfor

  cart_ix = sub2ind(size(track), pos(2, :), pos(1, :));
  crashes |= any((cart_ix == cart_ix') & ~eye(length(cart_ix)));

  ## if any(crashes)
  ##   for crash_ix = new_cart_ix(crashes)
  ##     [y x] = ind2sub(size(track), crash_ix);
  ##     printf("Crash at (%d, %d)\n", [x - 1; y - 1]);
  ##   endfor

  ##   for ix = new_cart_ix(~crashes)
  ##     [y x] = ind2sub(size(track), ix);
  ##     printf("Remaining carts at (%d, %d)\n", x - 1, y - 1);
  ##   endfor
  ## endif

  if ~first_crash && any(crashes)
    [sorted, order] = sort(cart_ix);
    first_crash = sorted(crashes(order))(1);
  endif

  track_with_carts = track;
  track_with_carts(cart_ix(crashes)) = 'X';

  cart_ix(crashes) = [];
  pos(:, crashes) = [];
  dpos(:, crashes) = [];
  turns(crashes) = [];

  track_with_carts(cart_ix(dpos(1, :) == 1)) = '>';
  track_with_carts(cart_ix(dpos(1, :) == -1)) = '<';
  track_with_carts(cart_ix(dpos(2, :) == 1)) = 'v';
  track_with_carts(cart_ix(dpos(2, :) == -1)) = '^';

  for i = 1:size(track_with_carts)(1)
    printf("%s\n", track_with_carts(i, :));
  endfor
  printf("\n%s\n\n", line);

  if n >= maxn
    break;
  endif
  n += 1;
until length(cart_ix) <= 1

if first_crash
  [y x] = ind2sub(size(track), first_crash);
  printf("The first crash occurred at (%d, %d)\n", x - 1, y - 1);
endif
[y x] = ind2sub(size(track), cart_ix);
printf("The last cart ended at (%d, %d)\n", x - 1, y - 1);

