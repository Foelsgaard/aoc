#! /usr/bin/octave -qf

args = argv();
if length(args) != 1
  printf("Invalid number of arguments\n");
  return
endif

input = args{1};

## First part
tree = load(input);


function [meta end_ix]=metadata(tree, ix)
  childcount = tree(ix);
  metacount = tree(ix+1);

  meta = [];
  jx = ix+2;
  for i=1:childcount
    [childmeta jx] = metadata(tree, jx);
    meta = [childmeta meta];
  end

  meta = [tree(jx:(jx + metacount - 1)) meta];
  end_ix = jx + metacount;
endfunction

printf("The sum of all metadata entries in the tree is %d\n", sum(metadata(tree, 1)));

## Second part
function [v end_ix]=value(tree, ix)
  childcount = tree(ix);
  metacount = tree(ix+1);

  childvalues = [];
  jx = ix+2;
  for i=1:childcount
    [childvalue jx] = value(tree, jx);
    childvalues = [childvalues childvalue];
  end

  metadata = tree(jx:(jx + metacount - 1));

  if childcount == 0
    v = sum(metadata);
  else
    v = sum(childvalues(metadata(metadata <= childcount)));
  endif
  end_ix = jx + metacount;
endfunction

printf("The value of the root node is %d\n", value(tree, 1));
