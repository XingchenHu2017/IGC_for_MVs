clear
clc

load('data.mat')

X = data(:,1:end-1);

percent = 'X_40';
prop = 0.40;   % proportion of missing values

%% generate missing values in the data set
compl_num = round(size(X,1)*size(X,2)*(1-prop));  % number of complete data

flag = zeros(size(X,1),size(X,2));  % flag of missing or not missing values
% 0 is nan, 1 is not missing values
for i = 1:size(X,1)
    flag(i,randi(size(X,2))) = 1;    % make sure each original feature vector retains at least one component
end
flag = flag';
flag_indx = find(flag==0);
temp_indx = randperm(size(flag_indx,1));
indx = temp_indx(1:(compl_num-size(X,1)));
flag(flag_indx(indx)) = 1;
flag = flag';
X(flag==0) = nan;
eval( [percent, '= [X data(:,end)];']);
X_incomplete = [X data(:,end)];

%count variables
X_incomplete(isnan(X_incomplete)==0) = 0;
X_incomplete(isnan(X_incomplete)) = 1;
final_prop = sum(sum(X_incomplete))/(size(X,1)*size(X,2))

% count instances
% count_X = sum(X_incomplete(:,1:end-1),2);
% count_X(isnan(count_X)==0) = 1;
% count_X(isnan(count_X)) = 0;
% final_prop = sum(count_X)/size(Data,1)

mdlfilename = [percent,'.mat'];
save(strcat(mdlfilename),percent)
