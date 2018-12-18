#! /usr/bin/octave -qf

args = argv();
if length(args) != 2
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};
maxn = str2num(args{2});

start_state = [];
fid = fopen(input);
do
  start_state(end+1,:) = fgetl(fid);
until feof(fid)
fclose(fid);

ext_state = start_state;
ext_state = prepad(ext_state, size(ext_state)(1) + 1, toascii('.'), 1);
ext_state = postpad(ext_state, size(ext_state)(1) + 1, toascii('.'), 1);
ext_state = prepad(ext_state, size(ext_state)(2) + 1, toascii('.'), 2);
ext_state = postpad(ext_state, size(ext_state)(2) + 1, toascii('.'), 2);

[xx yy] = meshgrid(1:3, 1:3);
neighborhood = sub2ind(size(ext_state), xx, yy) - sub2ind(size(ext_state), 2, 2);
neighborhood(5) = [];

[xx yy] = meshgrid(2:size(ext_state)(2)-1, 2:size(ext_state)(1)-1);
nix = sub2ind(size(ext_state), yy, xx) .+ permute(neighborhood, [3 1 2]);

previous = zeros([size(start_state) 10000]);

n = 0;
do
  state = ext_state(2:end-1, 2:end-1);
  num_trees = sum(ext_state(nix) == '|', 3);
  num_yards = sum(ext_state(nix) == '#', 3);
  tree = state == '|';
  yard = state == '#';
  open_area = state == '.';
  state(open_area & num_trees >= 3) = '|';
  state(tree & num_yards >= 3) = '#';
  state(yard & (num_yards == 0 | num_trees == 0)) = '.';
  ext_state(2:end-1, 2:end-1) = state;

  n += 1;
until n == maxn
resource_value = sum((state == '#')(:)) * sum((state == '|')(:));
printf("After %d minutes the total resource value is %d\n", n, resource_value);
