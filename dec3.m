#! /usr/bin/octave -qf

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};

## First part
fid = fopen(input);
overlap = zeros(1000, 1000);
do
  square = fgetl(fid);
  [id, x, y, w, h] = strread(square, "#%d @ %d,%d: %dx%d");

  ix = (x+1:x+w) .+ (y:y+h-1)' * 1000;
  overlap(ix) += 1;
until feof(fid)
fclose(input);

printf("%d square inches of fabric overlap\n", sum(sum(overlap > 1)));


## Second part
fid = fopen(input);
do
  square = fgetl(fid);
  [id, x, y, w, h] = strread(square, "#%d @ %d,%d: %dx%d");

  ix = (x+1:x+w) .+ (y:y+h-1)' * 1000;
  if sum(sum(overlap(ix))) == w * h
    printf("Square with id #%d does not overlap with any other square\n", id);
    break;
  endif
until feof(fid)
fclose(input);
