#! /usr/bin/octave -qf

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};

## Not a pretty or general solution

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
until max(pos(:, 2)) - min(pos(:, 2)) < 100

for i = 1:9
  pos += vel;
endfor
n += 9;

hf = figure();
plot(pos(:, 1), -pos(:, 2), '.');
axis([110, 210, -200, -100]);
print(hf, "message.png", "-dpng");
