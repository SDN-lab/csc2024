function [r2] = pseudoR2(rootfile,modelID,nopt,EM)
% Function to calculate the pseudo R squared of a model
%   calculated as follows: pseudo-r^2 = 1 - (L/R) where L is the log likelihood of the
%   observed data under the winning model and R is the log likelihood of the data under chance
%   (Camerer & Ho, 1999; Daw, 2011)
%
%   Written by Jo Cutler April 2020

% INPUT:       - rootfile: file with all behavioural information necessary for fitting + outputroot
%              - modelID: ID of model to fit
%              - nopt: number of options to choose from in the task, in
%                prosocial learning task = 2
%              - EM: binary flag to indicate whether the model was fit by
%                expectation maximisation (EM = 1) or
%                maximum likelihood (ML; EM = 0)
% OUTPUT:      - pseudo R squared of the model
%
% DEPENDENCIES: - mk_0mod (model fit for chance model for a given subject)

if nargin<4 % if whether the model was fit by EM or LM is not specified, check in model data
    EM = NaN;
    while isnan(EM)
        if isfield(rootfile, 'em') && ~isfield(rootfile, 'ml')
            EM = 1;
        end
        if ~isfield(rootfile, 'em') && isfield(rootfile, 'ml')
            EM = 0;
        end
        if isfield(rootfile, 'em') && isfield(rootfile, 'ml')
            if ~isempty(rootfile.em) && isempty(rootfile.ml)
                EM = 1;
            end
            if isempty(rootfile.em) && ~isempty(rootfile.ml)
                EM = 0;
            end
        end
        if isnan(EM)
            error('Cannot find em or ml model details in the model structure')
        end
    end
end

fitops = {'ml', 'em'};

if nargin<3 % if number of options not specified check whether task has known nopts
    nopt = NaN;
    while isnan(nopt)
        try
            if strcmp(rootfile.expname, 'ProsocialLearn') == 1
                nopt = 2;
            end
        catch
        end
        try
            if contains(modelID, 'RWPL') == 1
                nopt = 2;
            end
        catch
        end
        if isnan(nopt)
            error('Unable to check how many options there were in the experiment')
            %warning('Unable to check how many options there were in the experiment, assuming 2')
            %nopt = 2;
        end
    end
end

nr_trials_raw = size(rootfile.beh{1,1}.agent,1); % get number of trials
n_subj      = length(rootfile.beh); % get number of participants

nllModel = NaN;
while isnan(nllModel)
    try
        if isfield(rootfile.(fitops{EM+1}).(modelID).fit,'nll')
            for is = 1:n_subj
            nr_trials(is,1) = nr_trials_raw - length(find(rootfile.(fitops{EM+1}).(modelID).behaviour{1,is}.choice > 2));
            end
            nllModel = rootfile.(fitops{EM+1}).(modelID).fit.nll;
        end
    catch
    end
    try
        if isfield(rootfile.(fitops{EM+1}).(modelID){1, 1},'fval')
            for is = 1:n_subj
                nr_trials(is,1) = nr_trials_raw - sum(isnan(rootfile.(fitops{EM+1}).(modelID){is}.info.prob));  
                nllModel(is,1) = rootfile.(fitops{EM+1}).(modelID){1, is}.fval;
            end
        end
    catch
    end
    try
        if isfield(rootfile.(fitops{EM+1}).(modelID){1, 1}.info,'prob')
            for is = 1:n_subj
                nr_trials(is,1) = nr_trials_raw - sum(isnan(rootfile.(fitops{EM+1}).(modelID){is}.info.prob));
                ChoiceProb = rootfile.(fitops{EM+1}).(modelID){1, is}.info.prob;
                nllModel(is,1) = -nansum(log(ChoiceProb));
            end
        end
    catch
    end
    if isnan(nllModel)
        error('Unable to find either the model log likelihood or choice probabilities to calculate it')
    end
end

for is = 1:n_subj % calcuate the fit of the null model - repeated for the number of participants
    ntrials = nr_trials(is,1);
    [nllChance(is,1), aicChance(is,1), bicChance(is,1)] = mk_0mod(ntrials,nopt);
end

L = mean(nllModel);
R = mean(nllChance);

r2 = 1 - (L/R);

% L = median(nllModel);
% R = median(nllChance);
% 
% r2.median = 1 - (L/R);

end

