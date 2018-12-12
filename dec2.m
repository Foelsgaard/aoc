#! /usr/bin/octave -qf

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};

ids = textread(input, "%s");

## First part
sum_2chars = 0;
sum_3chars = 0;

for i=1:length(ids)
  id = ids{i};

  sum_2chars += any(sum(id == id') == 2);
  sum_3chars += any(sum(id == id') == 3);
endfor

checksum = sum_2chars * sum_3chars;

printf("The checksum for the input is %d\n", checksum);


## Second part
for i=1:length(ids)
  id1 = ids{i};
  for j=i+1:length(ids)
    id2 = ids{j};

    diff = id1 != id2;
    if sum(diff) == 1
      complement = not(diff);
      printf("The correct box IDs have '%s' in common\n", id1(complement));
      return
    end
  endfor
endfor
