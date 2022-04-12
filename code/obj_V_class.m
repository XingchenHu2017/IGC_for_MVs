function [U,V_class] = obj_V_class(data_all,V_opt, expo, conf_y)
    for i = 1:size(conf_y,2)

        center = V_opt{conf_y(:,i)==1}; % Select the prototypes of the same class as the data
        data = data_all(i,:);

        if sum(double(isnan(data))) ~= 0 
            I_kj = ones(size(data,1),size(data,2));
            I_kj(isnan(data)) = 0;
            data_0 = data;
            data_0(isnan(data)) = 0;          
            temp_u = sum(double(isnan(data_all)),2);
            [u,~] = find(temp_u~=0); % index of data with missing attributes
            pdata = data_all;
            pdata(u,:) = [];

            center = [center;pdata]; 
            cluster_n = size(center,1);
            dist = distfcm_pds(center, data);       % fill the distance matrix
            tmp = dist.^(-2/(expo-1));      % calculate new U, suppose expo != 1
            U{i} = tmp./(ones(cluster_n, 1)*sum(tmp));
            [~,indx] = min(dist);

            V_class(i,:) = center(indx,:);
        else
            U{i} = 1;
            V_class(i,:) = data; % The set of datasets without missing attributes for the same label
        end
    end
end

