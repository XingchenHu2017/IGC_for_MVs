function Q = obj_func0717(V,xx,trn_inputs,m,trn_targets,c,D)
    % the cross-entropy loss function :Q
    % Input variables:
    %   V: the initial prototype
    %   xx: variable horizontal vectors
    %   trn_inputs : Input data
    %   trn_targets : Target output
    for j = 1:length(c)
        tem_xx = mat2cell(xx',c*D);
        tem_xx = reshape(tem_xx{j},c(j),[]);
        V_opt{j} = V{j}+tem_xx;
    end
    % confidence distribution over the label space
    softmax_value_trn = func_scheme3(V_opt,trn_inputs,m);

    conf_trn_target = zeros(max(trn_targets),length(trn_targets));
    conf_trn_y = conf_trn_target;
    for trn_i = 1:size(trn_targets,1)
        conf_trn_target(trn_targets(trn_i),trn_i) = 1;
        [~,temp_i] = max(softmax_value_trn(trn_i,:));
        conf_trn_y(temp_i,trn_i) = 1;
    end
    % the cross-entropy loss function
    Q = crossentropy(conf_trn_y,conf_trn_target);
end