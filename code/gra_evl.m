function [tst_cov,tst_spe] = gra_evl(trn_granule,trn_input_true,tst_granule,tst_input_true)

tst_granule = [trn_granule;tst_granule];
tst_input_true = [trn_input_true;tst_input_true];

tst_cov = 0;
for i = 1:size(tst_granule,1)
    for j = 1:size(tst_input_true,2)
        if tst_granule(i,j*2-1)==tst_granule(i,j*2)
            tst_cov = tst_cov+1;
        else
            if tst_granule(i,j*2-1)<tst_input_true(i,j) &&...
                    tst_granule(i,j*2)>tst_input_true(i,j)
                tst_cov = tst_cov+1;
            end
        end
        
    
    end
end
for i = 1:size(tst_input_true,2)
    temp(:,i) = 1-abs((tst_granule(:,i*2)-tst_granule(:,i*2-1)))/...
        (max(tst_input_true(:,i))-min(tst_input_true(:,i)));
end

tst_cov = tst_cov/(size(tst_input_true,1)*size(tst_input_true,2));
tst_spe = sum(sum(temp))/(size(tst_input_true,1)*size(tst_input_true,2));
end

