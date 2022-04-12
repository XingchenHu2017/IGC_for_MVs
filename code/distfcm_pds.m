function out = distfcm_pds(center, data)
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

out = zeros(size(center, 1), size(data, 1));

% fill the output matrix

data_01 = data*0;
data_01(isnan(data_01)) = 1;
s_I = size(data,2)./(size(data,2)-sum(data_01,2));
if size(center, 2) > 1
    for k = 1:size(center, 1)
    temp_dist = (data-ones(size(data, 1), 1)*center(k, :)).^2;    
    temp_dist(isnan(temp_dist)) = 0;
    out(k, :) = sqrt(sum(temp_dist,2).*s_I);    
% 	out(k, :) = sqrt(sum(((data-ones(size(data, 1), 1)*center(k, :)).^2), 2));
    end
else	% 1-D data
    for k = 1:size(center, 1)
	out(k, :) = abs(center(k)-data)';
    end
end
