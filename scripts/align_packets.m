function [a, b] = align_packets(a, b)

n = min(size(a, ndims(a)), size(b, ndims(b)));

idx_a = repmat({':'}, 1, ndims(a));
idx_b = repmat({':'}, 1, ndims(b));

idx_a{end} = 1:n;
idx_b{end} = 1:n;

a = a(idx_a{:});
b = b(idx_b{:});

end