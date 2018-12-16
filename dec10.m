#! /usr/bin/octave -qf

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};

## Both parts

fid = fopen(input);
pos = [];
vel = [];
do
  particle = fgetl(fid);
  [x y dx dy] = strread(particle, "position=<%d, %d> velocity=<%d, %d>");
  pos(end+1,:) = [x y];
  vel(end+1,:) = [dx dy];
until feof(fid)
fclose(fid);

n = 0;
do
  pos += vel;
  n += 1;
until max(pos(:, 2)) - min(pos(:, 2)) <= 9

printf("The elves sent the following message in %d seconds\n", n);

xs = min(pos(:, 1)):max(pos(:, 1));
ys = min(pos(:, 2)):max(pos(:, 2));
for y = ys
  for x = xs
    if any(all(pos == [x y], 2), 1)
      printf("#");
    else
      printf(".");
    endif
  endfor
  printf("\n");
endfor
