#! /usr/bin/octave -qf

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};

walls = [];
goblins = [];
elves = [];
fid = fopen(input);
do
  line = fgetl(fid);
  walls = [walls line' == '#'];
  goblins = [goblins line' == 'G'];
  elves = [elves line' == 'E'];
until feof(fid)
fclose(fid);
walls = logical(walls);
goblins = goblins * 200;
elves = elves * 200;


function print_map(walls, goblins, elves)
  print_map_with_overlay(walls, goblins, elves, []);
endfunction

function print_map_with_overlay(walls, goblins, elves, overlay)
  pretty = zeros(size(walls));
  pretty(walls) = '#';
  pretty(~walls) = '.';
  pretty(goblins > 0) = 'G';
  pretty(elves > 0) = 'E';
  pretty(overlay > 0) = overlay(overlay > 0);
  for c = 1:columns(pretty)
    printf("%s", pretty(:, c));
    if any(goblins(:, c) > 0 | elves(:, c) > 0)
      printf("   ");
      for unit = find((goblins(:, c) > 0) | (elves(:, c) > 0))'
        if goblins(:, c)(unit)
          printf("G(%d) ", goblins(:, c)(unit));
        else
          printf("E(%d) ", elves(:, c)(unit));
        endif
      endfor
    endif
    printf("\n");
  endfor
endfunction

function d = distance(walls, a, b)
  [x1 y1] = ind2sub(size(walls), a);
  [x2 y2] = ind2sub(size(walls), b);
  d = sum(abs([x1 y1] .- permute([x2 y2], [3 2 1])), 2);
endfunction

function path = reconstruct_path(came_from, current)
  path = [current];
  while came_from(current) != 0
    current = came_from(current);
    path(end + 1) = current;
  endwhile
  path = fliplr(path);
endfunction

function n = neighbors(walls, src)
  [x y] = ind2sub(size(walls), src);
  xx = [0; 1; 0; -1] .+ permute(x, shift(1:length(size(y)) + 1, 1));
  yy = [-1; 0; 1; 0] .+ permute(y, shift(1:length(size(y)) + 1, 1));
  n = sub2ind(size(walls), xx, yy);
endfunction

function [path g_score] = path_to_target(walls, unit, target)
  visited = false(size(walls));
  came_from = zeros(size(walls));
  g_score = Inf(size(walls));
  f_score = Inf(size(walls));

  g_score(unit) = 0;

  ## Distance heuristic is not compatible with the exercise apparently. Causes non-reading-order paths to be taken.
  f_score(unit) = 0; ##distance(walls, unit, target);

  visited(unit) = true;
  next = [unit];

  while ~isempty(next)
    next = sort(next);
    [min_score ix] = min(f_score(next));
    current = next(ix);
    next(ix) = [];

    visited(current) = true;
    if current == target
      path = reconstruct_path(came_from, current);
      return;
    endif

    for neighbor = sort(neighbors(walls, current))'
      if visited(neighbor) || walls(neighbor)
        continue
      endif

      tentative_g_score = g_score(current) + 1;

      if all(next != neighbor)
        next(end + 1) = neighbor;
      elseif tentative_g_score >= g_score(neighbor)
        continue
      endif

      came_from(neighbor) = current;
      g_score(neighbor) = tentative_g_score;
      f_score(neighbor) = g_score(neighbor) + 0; ##distance(walls, neighbor, target);
    endfor
  endwhile
endfunction

function [target path distances] = search_for_target(walls, unit, targets)
  visited = false(size(walls));
  next = [unit];
  while ~isempty(next)
    current = next;

    visited(current) = true;

    ns = unique(neighbors(walls, current));
    ns = ns(~visited(ns) & ~walls(ns));

    target_neighbors = ns(targets(ns));

    if any(target_neighbors)
      target = min(target_neighbors);
      [path distances] = path_to_target(walls, unit, target);
      return
    endif

    next = ns;
  endwhile

  target = 0;
  path = [];
  distances = zeros(size(walls));
endfunction

function bm = ind2bitmap(walls, ix)
  bm = false(size(walls));
  bm(ix) = true;
endfunction

elf_attack_power = 4;
starting_goblins = goblins;
starting_elves = elves;
do
  elves = starting_elves;
  goblins = starting_goblins;

  printf("Elf attack power: %d\n", elf_attack_power);

  printf("Initial state\n")
  print_map(walls, goblins, elves);
  printf("\n");

  round = 0;

  while any((goblins > 0)(:)) && any((elves > 0)(:))
    round += 1;
    printf("Round %d\n", round);
    units = find(goblins > 0 | elves > 0);
    turn = 0;
    ended = false;
    for unit = units'

      if ~any((goblins > 0)(:)) || ~any((elves > 0)(:))
        ended = true;
        if turn < length(units)
          printf("Round finished early!\n");
          round -= 1;
        endif
        break;
      endif

      turn += 1;

      is_goblin = goblins(unit) > 0;

      if is_goblin

        if goblins(unit) == 0
          continue
        endif

        adjacent_to_enemies = ind2bitmap(walls, neighbors(walls, elves > 0));

        if ~adjacent_to_enemies(unit)
          [target path g_score] = search_for_target(walls | goblins > 0 , unit, adjacent_to_enemies);

          if target
            step = path(2);
            goblins(step) = goblins(unit);
            goblins(unit) = 0;
            unit = step;
          endif
        endif

        ns = sort(neighbors(walls, unit));
        min_hp = Inf;

        target = 0;
        for n = ns'
          if elves(n) > 0 && elves(n) < min_hp
            target = n;
            min_hp = elves(n);
          endif
        endfor

        if target
          elves(target) = max(elves(target) - 3, 0);
        endif

      else

        if elves(unit) == 0
          continue
        endif

        adjacent_to_enemies = ind2bitmap(walls, neighbors(walls, goblins > 0));

        if ~adjacent_to_enemies(unit)
          [target path g_score] = search_for_target(walls | elves > 0, unit, adjacent_to_enemies);

          if target
            step = path(2);
            elves(step) = elves(unit);
            elves(unit) = 0;
            unit = step;
          endif
        endif

        ns = sort(neighbors(walls, unit));
        min_hp = Inf;

        target = 0;
        for n = ns'
          if goblins(n) > 0 && goblins(n) < min_hp
            target = n;
            min_hp = goblins(n);
          endif
        endfor

        if target
          goblins(target) = max(goblins(target) - elf_attack_power, 0);
        endif

      endif
    endfor

    print_map(walls, goblins, elves);
    printf("\n");

    if ended
      break
    endif
    if sum((starting_elves > 0)(:)) != sum((elves > 0)(:))
      printf("An elf died - increasing elf power!\n");
      break
    endif
  endwhile
  elf_attack_power += 1;
until sum((starting_elves > 0)(:)) == sum((elves > 0)(:))

printf("Combat ends after %d fulls rounds\n", round);
if any((goblins > 0)(:))
  total_hit_points = sum(goblins(:));
  printf("Goblins win with %d total hit points left\n", total_hit_points);

else
  total_hit_points = sum(elves(:));
  printf("Elves win with %d total hit points left\n", total_hit_points);
endif
printf("Outcome: %d * %d = %d\n", round, total_hit_points, round * total_hit_points);
