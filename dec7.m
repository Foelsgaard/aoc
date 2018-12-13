#! /usr/bin/octave -qf

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};

## First part

fid = fopen(input);
step_ids = struct;
id_counter = 1;
do
  restriction = fgetl(fid);
  [antecedent_, succedent_] = strread(restriction, "Step %s must be finished before step %s can begin.");

  antecedent = antecedent_{1};
  succedent = succedent_{1};

  if not(isfield(step_ids, antecedent))
    step_ids.(antecedent) = id_counter;
    id_counter += 1;
  endif

  if not(isfield(step_ids, succedent))
    step_ids.(succedent) = id_counter;
    id_counter += 1;
  endif

  ant_id = step_ids.(antecedent);
  suc_id = step_ids.(succedent);

  graph(ant_id, suc_id) = 1;

until feof(fid)
fclose(fid);

[nodes, nodes_ix] = sort(fieldnames(step_ids));

n = nodes;
n_ix = nodes_ix;

i = 1;
while ~(isempty(n))
  s = sum(graph(n_ix, n_ix));
  [m, ix] = min(s);

  ordering(i) = n_ix(ix);

  n = n([1:ix-1 ix+1:end]);
  n_ix = n_ix([1:ix-1 ix+1:end]);

  i += 1;
endwhile

printf("The steps must be completed in the order %s\n", strcat(fieldnames(step_ids){ordering}));

## Bonus topological sort. Didn't realize this wasn't part of the exercise :(

g = graph;
g(g == 0 & ~(eye(size(g)))) = -Inf;

do
  old = g;
  g = permute(max(g .+ permute(g, [2 3 1])),[3 2 1]);
  changes = old != g;
until not(any(changes(1:end)))

nodes = fieldnames(step_ids);
[lex_sorted, lex_ix] = sort(nodes);
[top_sorted, top_ix] = sort(max(g)(lex_ix));

printf("The topological ordering of the steps is %s\n", strcat(nodes(lex_ix){top_ix}));

## Second part

[steps, lex_ix] = sort(fieldnames(step_ids));
required = index("ABCDEFGHIJKLMNOPQRSTUVWXYZ", steps) + 60;
progress = zeros(size(steps));
active = false(size(steps));
spent = 0;

do
  free_workers = max(0, 5 - sum(active));
  incomplete = progress != required;
  dependencies = sum(graph(lex_ix, lex_ix) & incomplete & incomplete');
  active(find((dependencies == 0) & incomplete', free_workers)) = true;
  progress(active) += 1;
  complete = progress == required;
  active(complete) = false;

  spent += 1;
until all(complete)

printf("The workers will take %d seconds to complete all the steps \n", spent);
