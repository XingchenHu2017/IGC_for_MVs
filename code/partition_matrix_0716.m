function [y,phi] = partition_matrix_0716( center, data, m )
%entries of the partition matrix
out = [];
% fill the output matrix
h = size(center,2);
c = size(center{1},1);

data_01 = data*0;
data_01(isnan(data_01)) = 1;
s_I = size(data,2)./(size(data,2)-sum(data_01,2));

c_num = 0;

if size(center, 2) > 1
    for i = 1:h
       V = center{i}; 
       c_num = [c_num size(V,1)];
       for j = 1: size(V,1)
           temp_dist = (data-ones(size(data, 1), 1)*V(j, :)).^2;
           temp_dist(isnan(temp_dist)) = 0;
           dis(j, :) = sqrt(sum(temp_dist,2).*s_I);           
       end
       out = [out;dis];
       dis = [];
    end   
else	% 1-D data
    for i = 1:h
       V = center{i}; 
       for j = 1:size(V,1)
           dis(k, :) = abs(V(j)-data)';
       end
       out = [out;dis];
    end  
end
out(out == 0) =NaN;
tmp = out.^(-2/(m-1));
y = tmp./(ones(sum(c_num), 1)*sum(tmp));



y(isnan(out)) = 1;
y(isnan(y)) = 0;
for i = 1:h
    phi(i,:) = max(y(sum(c_num(1:i))+1:sum(c_num(1:i+1)),:));
end

% tmp = out.^(2/(m-1));
% for n = 1:c*h
%     y(n,:) = (sum(ones(c*h, 1)*tmp(n,:)./tmp)).^(-1);
% end
end

