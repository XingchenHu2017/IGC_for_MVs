function [centers_pocs,U_pocs, X_pocs] = fcm_pocs(X,cluster_n,U) % N
% Objective Functions of POCS
% Input : 
%       X : the input data with missing variables
%       cluster_n : Number of clusters
%       U : Initial membership matrix
% Output:
%       centers_pocs : The cluster centers by POCS
%       U_pocs : New membership matrix
%       X_pocs : Data with missing attributes filled

    data = X;
    knn_mean = zeros(size(data));
    knn_var = zeros(size(data));
    Kjk = zeros(size(data));
    neighbor = cell(size(data));



    %  POCS_cluster
    data_n = size(data, 1);
    missing = isnan(data);
    Dist = @(x,y)dist_knn1(x,y);
    k = 8;
    Xm_temp = data(any(isnan(data),2),:);
    % Determine the k nearest neighbors of each incomplete data
    [Idx,D] = knnsearch(data,Xm_temp,'Distance',Dist,'k',k);
    row = find(sum(double(isnan(data)),2) > 0);
    alpha = 0.05;
    % Check the corresponding attribute values of the k nearest neighbors of each missing value to see
    % whether they are governed by the Gaussian distribution
    for i = 1:size(Xm_temp,1)
            k = row(i);
            n = find(isnan(Xm_temp(i,:)) == 1) ;
        for j = 1:size(n,2)
            % determine the probability density of missing value; if yes,
            % Kjk = 1; else Kjk = 0;
            x = sort(data(Idx(i,:)',n(j)));
            if length(unique(x(~isnan(x)))) ==1
                Kjk(k,n(j)) = 0;
            elseif length(x(~isnan(x))) < 3
                Kjk(k,n(j)) = 0;
            else
                [H, pValue, W] = swtest(x, alpha);
                knn_mean(k,n(j)) = mean(x);
                knn_var(k,n(j)) = var(x); 
                if H == 0
                    Kjk(k,n(j)) = 1;
                else
                    Kjk(k,n(j)) = 0;
                end
            end
            neighbor{k,n(j)} = x;
        end
    end
    m = 2;
    K = 0.02; 
    stop_iter = 10.^(-6);

    X_m = fillmissing(data,'movmedian',10);
    X_m = fillmissing(X_m,'linear',2,'EndValues','nearest');

    X_m = X_m.*missing; % the set of missing attribute values
    X_p = data;
    X_p(isnan(X_p)) = 0; % the set of the available attribute values
    options = [2.0 400 stop_iter 0];
    % Update centers_pocs, U_pocs ,X_pocs
    [centers_pocs, U_pocs ,X_pocs] = tri_fcm(missing,X_p ,X_m, cluster_n, U, options,K,Kjk,knn_mean,knn_var);
end


