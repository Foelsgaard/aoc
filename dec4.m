#! /usr/bin/octave -qf

                                # Assumes sorted input

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};

## First part
fid = fopen(input);

schedule = struct;
do
  event = fgetl(fid);

  timestamp = event(1:18);
  description = event(20:end);
  [year, month, day, hour, minute] = strread(timestamp, "[%d-%d-%d %d:%d]");

  if strcmp(description, "falls asleep")
    sleep_start = minute;
  elseif strcmp(description, "wakes up")
    sleep_end = minute;
    if not(isfield(schedule, id))
      schedule.(id) = zeros(1, 60);
    endif
    schedule.(id)((sleep_start:sleep_end)+1) += 1;
  else
    id = strread(description, "Guard %s begins shift"){1};
  endif

until feof(fid)
fclose(input);

ids = fieldnames(schedule);


max_asleep = 0;

for i=1:length(ids)
  id = ids{i};

  asleep = sum(schedule.(id));
  if asleep > max_asleep
    max_asleep = asleep;
    most_asleep_id = id;
    [m, minute] = max(schedule.(id));
  endif
endfor

printf("Guard %s was asleep the most and is most likely to be asleep at minute %d -- the product of the id and minute is %d\n", most_asleep_id, minute-1, strread(most_asleep_id, "#%d") * (minute - 1));

## Second part
max_number_of_times_asleep = 0;
for i=1:length(ids)
  id = ids{i};

  [number_of_times_asleep, minute] = max(schedule.(id));

  printf("%d, %d\n", number_of_times_asleep, minute);

  if number_of_times_asleep >= max_number_of_times_asleep
    max_number_of_times_asleep = number_of_times_asleep;
    minute_most_asleep = minute;
    most_asleep_id = id;
  endif
endfor

printf("Guard %s spent minute %d asleep more times than any other guard or minute -- the product of the id and minute is %d\n", most_asleep_id, minute_most_asleep-1, strread(most_asleep_id, "#%d") * (minute_most_asleep - 1));
