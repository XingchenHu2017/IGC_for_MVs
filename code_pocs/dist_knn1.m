function out = dist_knn1(x,data)
%DISTFCM Distance measure in fuzzy c-mean clustering.
%	OUT = DISTFCM(CENTER, DATA) calculates the Euclidean distance
%	between each row in CENTER and each row in DATA, and returns a
%	distance matrix OUT of size M by N, where M and N are row
%	dimensions of CENTER and DATA, respectively, and OUT(I, J) is
%	the distance between CENTER(I,:) and DATA(J,:).
%
%       See also FCMDEMO, INITFCM, IRISFCM, STEPFCM, and FCM.

%	Roger Jang, 11-22-94, 6-27-95.
%       Copyright 1994-2016 The MathWorks, Inc. 
% 
% out = zeros(size(data, 1)+1);

% fill the output matrix
data_01 = data*0;
data_01(isnan(data_01)) = 1;

temp_idex = logical(zeros(size(data)));
n = find(double(isnan(x)) == 1);
data_01(:,n) = 1;
s_I = size(data,2)./(size(data,2)-sum(data_01,2));

% fun = @(a,b) sqrt((sum(fillnan((a-b).^2),2)).*s_I);
% C = bsxfun(fun,data,data);
%     for k = 1:size(data, 1)
%     temp_out = zeros(size(x,1),1);

    temp_idex(:,n) = isnan(data(:,n));
%     temp_dist = data - x(k,:);
     temp_dist = bsxfun(@minus,data,x);
%     temp_dist = (data-ones(size(data, 1), 1)*center(k, :)).^2; 
    temp_dist(isnan(temp_dist)) = 0;
    temp_dist(temp_idex) = Inf;
    out = sqrt(sum(temp_dist.^2,2).*s_I);  
    out(isnan(out)) = Inf;

%     temp_out(k) = sqrt(sum(temp_dist.^2,2).*s_I);   
%     out = [out; temp_out];
% 	out(k, :) = sqrt(sum(((data-ones(size(data, 1), 1)*center(k, :)).^2), 2));

    
end