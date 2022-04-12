clear
clc
data_name = 'iris'; 

percent_all = {'X_00','X_10','X_20','X_30','X_40'}; %Percentage of missing data
class_num = 3;  % the number of class
c_all = 2:3:30; % the number of clusters

currentFolder = pwd;
%addpath(genpath(currentFolder));
addpath('./code_pocs')
 %path = 'C:\Users\UserNudt\Desktop\incomplete\paper2\';
for percent_num = 2:2  %1:size(percent_all,2)    
    percent = percent_all{percent_num};
	for cnum = 1:length(c_all)        
        for fold = 1:5           
            
           
            load(strcat('.\',data_name,'\flag_group.mat')) %Index vectors for cross-validation dividing the training and test sets
            load(strcat('.\',data_name,'\X_00.mat'))
            load(strcat('.\',data_name,'\',percent,'.mat'))
            load(strcat('.\',data_name,'\data.mat'))
            
            mm = 2;%fuzzification coefficient: [1.1 2 3] 
            expo = mm;
            
            % split train and test data
            X0 = eval('X_00');
            X = eval(percent);
            % train data
            train_flag = Trainflag{fold};
            trn_inputs = X(train_flag,1:end-1);
            trn_targets = X(train_flag,end);
            
            label = unique(trn_targets);
            % test data
            test_flag = Testflag{fold};
            tst_inputs = X(test_flag,1:end-1);
            tst_targets = X(test_flag,end);
           %% main code
            % Guied by informatoin granules in the label space 
            for j = 1:length(label)
                trn_data_part{1,j} = trn_inputs(X(train_flag,end)==label(j),:);
                range{j} = [min(trn_data_part{1,j});max(trn_data_part{1,j})];
            end
            h = max(label);
            
 %%---------------original strategy----------------------------------------
            c = c_all(cnum);  
            v_num = ones(1,h)*c;
            
            for j = 1:h
                U0 = initfcm(v_num(j), size(trn_data_part{1,j}, 1)); % Initialize the membership matrix
                % none missing
                %[center{j}, temp_U, obj_fcn] = fcm_modif(trn_data_part{1,j} ,v_num(j), U0, options_c);
                % values missing
                [center{j},temp_U, X_pocs] = fcm_pocs(trn_data_part{1,j},v_num(j),U0);
                U{j} = temp_U;
                V{j} = center{j};
            end            
            V_tmp{cnum} = V;
                       
            D = size(trn_inputs,2);
            % Calculate the upper and lower bounds of the subspace
            limit_j = [];
            for j = 1:h
                limit{j} = [(kron(range{j},ones(v_num(j),1))-repmat(V{j},2,1))];
            end

%%---------------Optimization of the initial fuzzy classifier----------------------------------------            
            % Initialization parameters
            problem_size = sum(v_num) * D;            
            lb = [];
            ub = [];
            for j = 1:h
                temp = limit{j};
                lb = [lb reshape(temp(1:v_num(j),:),1,[])];
                ub = [ub reshape(temp(v_num(j)+1:end,:),1,[])];
            end            
            max_fval = inf;
            
            for tryi = 1:1
                % population setting
                pop_size = 100;
                % Objective function
                fun2 = @(xx) obj_func0717(V,xx,trn_inputs,mm,trn_targets,v_num,D); 
                options = optimoptions('particleswarm','SwarmSize',pop_size,'MaxIter',1000,'InertiaRange',[0.9,0.9],'SelfAdjustmentWeight',0.5,'SocialAdjustmentWeight',0.3,'Display','off');
                % Particle swarm optimization algorithm
                [solution,fval2,exitflag,output] = particleswarm(fun2,problem_size,lb,ub,options);
                if fval2<max_fval
                    max_fval = fval2;
                    solution_v_tmp{cnum} = solution;
                end
            end
            
            % Optimized prototype
            solution2 = solution_v_tmp{cnum}; 
            for j = 1:h
                tem_xx = mat2cell(solution2',v_num*D);
                tem_xx = reshape(tem_xx{j},v_num(j),[]);
                V_opt{j} = V{j}+tem_xx;
            end 
            V_opt_tmp{cnum} = V_opt;
      
            % training data
            softmax_value_trn = func_scheme3(V_opt,trn_inputs,mm);
            
            conf_trn_target = zeros(class_num,length(trn_targets));
            conf_trn_y = conf_trn_target;
            for trn_i = 1:size(trn_targets,1)
                conf_trn_target(trn_targets(trn_i),trn_i) = 1;
                [~,temp_i] = max(softmax_value_trn(trn_i,:));
                conf_trn_y(temp_i,trn_i) = 1;
            end
            
            %test data
            softmax_value_tst = func_scheme3(V_opt,tst_inputs,mm);
            
            conf_tst_target = zeros(class_num,length(tst_targets));
            conf_tst_y = conf_tst_target;
            for tst_i = 1:size(tst_targets,1)
                conf_tst_target(tst_targets(tst_i),tst_i) = 1;
                [~,temp_i] = max(softmax_value_tst(tst_i,:));
                conf_tst_y(temp_i,tst_i) = 1;
            end
            % Classification confusion matrix
            [trn_acc(fold),~,~,trn_results{fold}]= confusion(conf_trn_target,conf_trn_y);  %plotconfusion
            [tst_acc(fold),~,~,tst_results{fold}] = confusion(conf_tst_target,conf_tst_y);
            
            trn_acc(fold) = 1-trn_acc(fold); % Classification Accuracy in train = 1 -  Confusion value;
            tst_acc(fold) = 1-tst_acc(fold);
            
            V_opt_all{cnum,fold} = V_opt;
            conf_trn_y_all{cnum,fold} = conf_trn_target;
            conf_tst_y_all{cnum,fold} = conf_tst_y;
            
%--------------------------The information granule imputation method-------------------------------------       
            % 1.center identification
            [trn_U,trn_V_class] = obj_V_class(trn_inputs,V_opt, expo, conf_trn_y);
            [tst_U,tst_V_class] = obj_V_class(tst_inputs,V_opt, expo, conf_tst_y);
            
            for j = 1:size(tst_V_class,1)
                ll = find(conf_tst_y(:,j)==1);
                data_labeled_tst(j,:) = [tst_inputs(j,:) ll];
            end
            
            labeled_data_all = [X(train_flag,1:end);data_labeled_tst];
            % 2.bounds optimization
            
            % information granules of training data
            temp_prototypes = [];
            for j = 1:size(trn_V_class,1)
                temp_granule = [];
                Dist = @(x,y)dist_knn1(x,y);
                for n = 1:size(trn_V_class,2)
                    if isnan(trn_inputs(j,n))
                        % Data with missing attributes
                        ll = find(conf_trn_y(:,j)==1);
                        labeled_data = labeled_data_all(labeled_data_all(:,end)==ll,1:end-1);
                        [Idx,~] = knnsearch(labeled_data,trn_V_class(j,:),'Distance',Dist,'k',round(size(labeled_data,1)/10));
                        neighbors = labeled_data(Idx,:);
                        % bounds optimization with missing attributes
                        [a, b, opti_cov(j,n),opti_spe(j,n)] = interval_bound(trn_V_class(j,n),neighbors(:,n));
                        temp_granule = [temp_granule [a, b]];
                    else
                        % Data without missing attributes
                        temp_granule = [temp_granule [trn_inputs(j,n), trn_inputs(j,n)]];
                        opti_cov(j,n) = 1;
                        opti_spe(j,n) = 1;
                    end
                end
                trn_granule(j,:) = temp_granule; % Interval Information Granules
            end
            trn_cov(cnum,fold) = mean(mean(opti_cov));
            trn_spe(cnum,fold) = mean(mean(opti_spe));
            
            
            % information granules of testing data
            opti_cov = [];
            opti_spe = [];
            temp_prototypes = [];
            for j = 1:size(tst_V_class,1)
                temp_granule = [];
                for n = 1:size(tst_V_class,2)
                    if isnan(tst_inputs(j,n))
                        % Data with missing attributes
                        ll = find(conf_tst_y(:,j)==1);
                        labeled_data = labeled_data_all(labeled_data_all(:,end)==ll,1:end-1);
                        [Idx,~] = knnsearch(labeled_data,tst_V_class(j,:),'Distance',Dist,'k',round(size(labeled_data,1)/10));
                        neighbors_tst = labeled_data(Idx,:);
                        % bounds optimization with missing attributes
                        [a, b, opti_cov(j,n),opti_spe(j,n)] = interval_bound(tst_V_class(j,n),neighbors_tst(:,n));
                        temp_granule = [temp_granule [a, b]];
                    else
                        % Data without missing attributes in testing
                        temp_granule = [temp_granule [tst_inputs(j,n), tst_inputs(j,n)]];
                        opti_cov(j,n) = 1;
                        opti_spe(j,n) = 1;
                    end
                end
                tst_granule(j,:) = temp_granule;
            end
            tst_cov(cnum,fold) = mean(mean(opti_cov));
            tst_spe(cnum,fold) = mean(mean(opti_spe));
            
            tst_input_true = X0(test_flag,1:end-1);
        end        
        trn_acc_c_all{cnum} = (trn_acc);
        tst_acc_c_all{cnum} = (tst_acc)
        
        tst_mean_value(cnum) = mean(tst_acc);        
    end
end

