function [center, U,X_M] = tri_fcm(Miss,data_P,data_M, cluster_n, U_0, options,K,Kjk,knn_mean,knn_var)
%Data set clustering using POCS clustering.
% Input : 
%       Miss : the index matrix of missing attribute values
%       data_M : the set of missing attribute values
%       data_P : the set of the available attribute values
%       cluster_n : Number of clusters
%       U0 : Initial membership matrix
%       options : Parameters
%       K : gain factor (a positive number) 
%       knn_mean/knn_var : numerical characteristics(mean value, variance) of missing values
% Output:
%       centers : The cluster centers 
%       U : New membership matrix
%       X_M : Data with missing attributes filled


if nargin ~= 10 && nargin ~= 11 && nargin ~= 14
	error(message("fuzzy:general:errFLT_incorrectNumInputArguments"))
end

data_n = size(data_M, 1);

% Change the following to set default options
default_options = [2;	% exponent for the partition matrix U
		100;	% max. number of iteration
		1e-5;	% min. amount of improvement
		1];	% info display during iteration 

if nargin == 3
	options = default_options;
else
	% If "options" is not fully specified, pad it with default values.
	if length(options) < 5
		tmp = default_options;
		tmp(1:length(options)) = options;
		options = tmp;
	end
	% If some entries of "options" are nan's, replace them with defaults.
	nan_index = find(isnan(options)==1);
	options(nan_index) = default_options(nan_index);
	if options(1) <= 1
		error(message("fuzzy:general:errFcm_expMustBeGtOne"))
	end
end

expo = options(1);		% Exponent for U
max_iter = options(2);		% Max. iteration
min_impro = options(3);		% Min. improvement
display = options(4);		% Display info or not

U_new = cell(max_iter,1);
X_M = zeros(size(data_M));
U = U_0;
X = data_P+data_M;
% Main loop
for i = 1:max_iter
    [U, data_M, center] = tri_stepfcm(Miss,data_P,data_M, U, cluster_n, expo,K,Kjk,knn_mean,knn_var);
    U_new(i) = {U};
	% check termination condition
	if i > 1
        fun = @(A,B) max(max((abs(A-B))));
		if bsxfun(fun,U_new{i},U_new{i-1}) < min_impro, break; end
	end
end

iter_n = i;	% Actual number of iterations 
U = U_new(iter_n);
X_M = data_M;

