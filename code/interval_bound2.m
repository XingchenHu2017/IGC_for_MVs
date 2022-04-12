function [aOptimal, bOptimal,opti_cov,opti_spe] = interval_bound2(center,data,input_data)
% targets data are considered
data = data(~isnan(data));

% [f,xi] = ksdensity(data); 
% plot(xi,f)

if isempty(data)
    data = [center*0.8;center*1.2];
end

Upper = max(data);
Lower = min(data);
m = center;

if Upper<m
    Upper = m;
elseif Lower>m
    Lower = m;
end

idxB=find(data>=m); % similar to triangular do not include m itself
partBdata = data(idxB);
PB = length(partBdata);
idxA=find(data<=m);
partAdata = data(idxA);
PA = length(partAdata);

beta = 1;
eps = 1; %will not change
NumofStep = 100; % could be changed to larger value,say 200,to make better plots

if Upper == m
    bOptimal = Upper;
    bOpti_cov = 1;
    bOpti_spe = 1;
else
    
    % optimization of partB--------------------------------------------------
    stepSize = (Upper - m) / NumofStep;
    bsize = floor((Upper - m)/stepSize)+1;
    if isnan(bsize)
        test=1;
    end
    
    allB = m:stepSize:Upper; % optimal b would be piced from here
    cov = zeros(1,bsize);
    spe = zeros(1,bsize);
    vPartB = zeros(1,bsize);
    
    i = 0; % counter to index b
    for b = m:stepSize:Upper
        i = i + 1;
        
        if i == NumofStep+1
            b = Upper;
        end
        % coverage of b
        idxb = find(partBdata<=b);
        cov(i) = length(idxb)/PB;
        % specificity of the specific b
        spe(i) = 1 - (b - m)/(Upper - m)/eps;
        % get the objective value
        vPartB(i) = cov(i) * spe(i)^beta;
    end
    
    [vPartB_max,idxPartB] = max(vPartB);
    
    % pick the optimal b
    bOptimal = allB(idxPartB);
    bOpti_cov = cov(idxPartB);
    bOpti_spe = spe(idxPartB);
end

% % % plot the partB curve
% % figure
% % P = length(data);
% % % scatter(data1D,zeros(1,P)) % original data set
% % plot(data,zeros(1,P),'ok') % with full axis
% % ylim([0,1.2])
% % % xlim([0,10])
% % hold on
% % bplot = m : stepSize : bOptimal;
% % bplot_y = ones(1,size(bplot,2));
% % plot(bplot,bplot_y,'k','linewidth',1.5)
% % plot([m,m],[0,1],':k','linewidth',1.5)
% % plot([bOptimal,bOptimal],[0,1],'k','linewidth',1.5)% plot the boundary

if m == Lower
    aOptimal = Lower;
    aOpti_cov = 1;
    aOpti_spe = 1;
else
    
    % optimization of partA-------------------------------------------------
    stepSize = (m - Lower) / NumofStep;
    asize = floor((m - Lower)/stepSize)+1;
    allA = m:-stepSize:Lower; % optimal a would be piced from here
    covA= zeros(1,asize);
    speA = zeros(1,asize);
    vPartA = zeros(1,asize);
    
    i = 0; % counter to index a
    for a = m:-stepSize:Lower
        i = i + 1;
        
        if i == NumofStep+1
            a = Lower;
        end
        % coverage of the specific a
        idxa = find(partAdata>=a);
        covA(i) = length(idxa)/PA; % coverage of a
        % specificity of the specific a
        speA(i) = 1 - (m - a)/(m - Lower)/eps;
        % get the objective value
        vPartA(i) = covA(i) * speA(i)^beta;
    end
    
    [vPartA_max,idxPartA] = max(vPartA);
    % pick the optimal a
    aOptimal = allA(idxPartA);
    aOpti_cov = covA(idxPartA);
    aOpti_spe = speA(idxPartA);
end

opti_cov = (aOpti_cov*PA+bOpti_cov*PB)/length(input_data(~isnan(input_data)));
if isempty(opti_cov)
    opti_cov = 0;
end

Upper = max(input_data(~isnan(input_data)));
Lower = min(input_data(~isnan(input_data)));

try
    opti_spe = 1-abs(bOptimal-aOptimal)/(Upper-Lower);
catch
    opti_spe = 1;
end
end

