function [U_new, X_M, center] = tri_stepfcm(Miss,data_P,data_M, U, cluster_n, expo,K,Kjk,knn_mean,knn_var)
%global U_new X_M
%tri_stepfcm One step in POCS clustering.

mf = U.^expo;       % MF matrix after exponential modification
data = data_P + data_M;
numCons = K.* Kjk./ (knn_var.^2);
center = mf*data./(sum(mf,2)*ones(1,size(data,2))); %new center
X_M = ((2*(center'* mf))'+ numCons.*knn_mean)./((2*repmat(sum(mf),size(data,2),1))'+ numCons);
X_M(isnan(X_M)) = 0;
data = X_M+data_P;
dist = distfcm(center, data);       % fill the distance matrix %
tmp = dist.^(-2/(expo-1));      % calculate new U, suppose expo != 1
U_new = tmp./(ones(cluster_n, 1)*sum(tmp));

