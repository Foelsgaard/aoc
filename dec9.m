#! /usr/bin/octave -qf

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};

## Both parts

fid = fopen(input);
[numplayers last_marble] = strread(fgetl(fid), "%d players; last marble is worth %d points");
fclose(fid);

score = zeros(1, numplayers);
left = [0];
current = 1;
right = [];

player = 2;
n = 2;
for last_marble = [last_marble last_marble*100]
  for marble=2:last_marble
    if n == 23
      score(player) += marble;
      if length(left) >= 7
        score(player) += left(end - 6);
        right(end + 1) = current;
        current = left(end - 5);
        right(end+1:end+5) = fliplr(left(end - 4:end));
        left = left(1:end - 7);
      elseif length(left) == 6
        score(player) += right(1);
        right(1) = [];
        right(end+1) = current;
        current = left(1);
        right(end+1:end+5) = fliplr(left(2:end));
        left = [];
        [left current fliplr(right)]
      else
        score(player) += right(7 - length(left));
        tmp = current;
        current = right(6 - length(left));
        right = [right(8 - length(left):end) tmp fliplr(left) right(1:5 - length(left)) ];
        left = [];
      endif

      n = 1;
    else
      if isempty(right)
        right = [left(1) current fliplr(left(2:end))];
        left = [];
        current = marble;
      else
        left(end+1) = current;
        left(end+1) = right(end);
        current = marble;
        right(end) = [];
      endif
      n += 1;
    endif
    if player == numplayers
      player = 1;
    else
      player += 1;
    endif
  endfor
  printf("%d players; last marble is worth %d points: high score is %d\n", numplayers, last_marble, max(score));
endfor
