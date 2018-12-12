#! /usr/bin/octave -qf

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};

## First part
base_polymer = fileread(input)(1:end-1);

polymer = base_polymer;
do
  shifted = [polymer(2:end) '0'];

  reaction = (isupper(polymer) == islower(shifted)) & (lower(polymer) == lower(shifted));
  reaction = [diff([0 reaction])] == 1;
  reaction |= [0 reaction(1:end-1)];

  polymer = polymer(not(reaction));

until not(any(reaction))

printf("The length of the resulting polymer is %d\n", length(polymer));

## Second part
types = unique(lower(base_polymer));

minimum_length = Inf;
for type=types

  polymer = base_polymer(not(lower(base_polymer) == type));
  do
    shifted = [polymer(2:end) '0'];

    reaction = (isupper(polymer) == islower(shifted)) & (lower(polymer) == lower(shifted));
    reaction = [diff([0 reaction])] == 1;
    reaction |= [0 reaction(1:end-1)];

    polymer = polymer(not(reaction));

  until not(any(reaction))

  if length(polymer) < minimum_length
    minimum_length = length(polymer);
    best_type = type;
  endif
endfor

printf("The shortest polymer was found by removing type %s/%s and has length %d\n", upper(best_type), best_type, minimum_length);
