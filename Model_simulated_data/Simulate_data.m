%% Data simulation script

%%% Jo Cutler 2024, adpated from script written by Pat Lockwood & Marco Wittmann 2019
%%% simulation script for parameter recovery for effort discounting models
%%%

close all;
clearvars;

addpath('models');
addpath('tools');

% Specify model with which to generate simulated behaviour
% -------------------------------------------- %

% models = {'two_k_one_beta', 'two_k_one_beta_linear', 'two_k_one_beta_hyperbolic'...
%     'two_k_two_beta', 'two_k_two_beta_linear', 'two_k_two_beta_hyperbolic'};

%models = {'two_k_one_beta_linear'};
models = {'two_k_one_beta_hyperbolic'};
modelsTR = 1; % enter the model number to run PR on - numerical index in models variable **

% Load in schedule
% -------------------------------------------- %

load trialorderPM.mat % specify trial order file here **
nTrls = size(trials.agent,1);

minEffort = min(trials.effort); % minimum effort level
maxReward = max(trials.reward); % maximum reward level

betamin = 0; % enter bounds on beta values here **
betamax = 5;
kmin = 0;
% kmax calculated below as depends on model

rng default % resets the randomisation seed to ensure results are reproducible (MATLAB 2019b)

for m = modelsTR % loop over model number(s) specified above
    
    clearvars -except models* *bounds *min *max m trials
    close all;
    
    modelID = models{m};
    % maximum k calculated as the discount rate that means the maximum reward and minimum effort has a value of 0
    kmax = maxValue(trials, modelID);
    
    lb = [kmin, kmin, betamin]; % lower bounds for all parameters
    ub = [kmax, kmax, betamax]; % upper bounds for all parameters
    if contains(modelID, 'two_beta') % add extra beta if model has two
        lb = [lb, betamin];
        ub = [ub, betamax];
    end
    
    params = get_params(modelID); % if adding new model functions also add the parameters here **
    nParam  = length(params);
    
    msg = ['Running parameter recovery for ', modelID, ', calculating ', num2str(nParam), ' parameters: ', char(params{1})];
    for n = 2:nParam
        msg = [msg, ', ', char(params{n})];
    end
    disp(msg) % show details in command window
    
    % Set parameters to simulate
    % -------------------------------------------- %
    
    grid.k = [0.1,1,1.9]; % define grid values **
    grid.beta = [1,3,5]; % define grid values **
    
    for ip=1:length(params)
        thisp=params{ip};
        if contains(thisp, 'k') == 1
            grid.all{ip} = grid.k;
        elseif contains(thisp, 'beta') == 1
            grid.all{ip} = grid.beta;
        else
            error('Define parameter as one of above cases');
        end
    end
    allCombs = combvec(grid.all{1:end})';
    nSubj = size(allCombs,1);
    trueParam = []; fittedParam = [];
    
    % Loop over each combinations of parameters
    % -------------------------------------------- %
    
    for is=1:nSubj
        
        data(is).ID        = sprintf('Subj %i',is);
        data(is).agent     = trials.agent(:,1);
        data(is).effort    = trials.effort(:,1);
        data(is).reward    = trials.reward(:,1);
        data(is).trueParam = allCombs(is,:);
        
        disp(['Combination ',num2str(is) ' of ',num2str(nSubj)]);
        
        simfunc = str2func('all_simulate');
        
        % Simulate choices
        % -------------------------------------------- %
        
        [data(is).data] = simfunc(data(is).effort, data(is).reward, data(is).agent, data(is).trueParam, modelID);
        
        % Fit choices
        % -------------------------------------------- %
        
        p = rand(nParam,1)' .* ub; % free parameters set to random
        options = optimset('Display', 'off');
       
        [p,fval,ex] = fmincon(@all_real, p,[],[],[],[],lb,ub,[], options, data(is).data, data(is).effort, data(is).reward, data(is).agent, modelID);
        data(is).fittedParam = p;

        trueParam = [trueParam;data(is).trueParam];
        fittedParam = [fittedParam;data(is).fittedParam];
        
    end
    
    % Plot recovery of params
    % -------------------------------------------- %
    
    params = strrep(params, '_', ' ');
    row = 1;
    figure('color','w');
    for param=1:nParam % plot correlations
        subplot(1,nParam,param);
        plot(trueParam(:,param),fittedParam(:,param),'k.','MarkerSize',12);
        all_corr(param,:) = corr(trueParam(:,param),fittedParam(:,param));
        hold on;box off;title(params{param});xlabel('true param');ylabel('fitted param');
        
        % Generate confusion matrix of all parameters correlated with eachother
        for param2=1:nParam
            confusion(row,1) = param;
            confusion(row,2) = param2;
            confusion(row,3) = corr(trueParam(:,param), fittedParam(:,param2));
            row = row  + 1;
        end
        
    end
  
    % Display and save correlations
    % -------------------------------------------- %
    
    msg = ['Finished parameter recovery for ', modelID, ', calculated ', num2str(nParam), ' parameters.', newline, 'Correlations between true and fitted parameters are: ', newline, char(params{1}), ': ', num2str(all_corr(1))];
    for n = 2:nParam
        msg = [msg, newline, char(params{n}), ': ', num2str(all_corr(n))];
    end
    disp(msg)
    
    conftab = cell2table(num2cell(confusion), 'VariableNames', {'Simulated', 'Recovered', 'MLCorr'});
%     writetable(conftab,['Parameter_recovery_mle.csv'],'WriteVariableNames',true) % uncomment to save results for plotting     

    
end
