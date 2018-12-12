#! /usr/bin/octave -qf

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};
freqs = csvread(input);

## First part
printf("The final frequency is %d\n", sum(freqs));

## Second part

previous_freqs = [];
current_freq = 0;

i = 1;
while not(ismember(current_freq, previous_freqs))
  previous_freqs = union([current_freq], previous_freqs);
  current_freq += freqs(i);

  i += 1;
  if i > length(freqs)
    i = 1;
  endif
endwhile

printf("The first repeated frequency is %d\n", current_freq);
