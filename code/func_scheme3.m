function [output] = func_scheme3(V,trn_inputs,m)
% The confidence belongingness (class member-ship value) fitto the t-th class
[~,active] = partition_matrix_0716( V, trn_inputs, m );
% a confidence distribution over the label space
output = (softmax(active))';
end