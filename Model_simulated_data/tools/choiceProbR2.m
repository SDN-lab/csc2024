
function [rootfile] = choiceProbR2(rootfile,modelID,EM)

% Function to calculate R squared of a model based on the choice
% probabilities: calculated using either the median or mean
%
%   Written by Jo Cutler April 2020

% INPUT:       - rootfile: file with all behavioural information necessary for fitting + outputroot
%              - modelID: ID of model to fit
%              - EM: binary flag to indicate whether the model was fit by
%                expectation maximisation (EM = 1) or
%                maximum likelihood (ML; EM = 0)
% OUTPUT:      - choice probability R squared of the model

if nargin<3 % if whether the model was fit by EM or LM is not specified, check in model data
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

nr_trials_raw = size(rootfile.beh{1,1}.agent,1); % get number of trials
n_subj      = length(rootfile.beh); % get number of participants

if EM == 0
    try
        for is = 1:n_subj
            rootfile.(fitops{EM+1}).fit.(modelID).eachSubProbMean(is,1) = nanmean(nanmean(rootfile.(fitops{EM+1}).(modelID){is}.info.prob));
            rootfile.(fitops{EM+1}).fit.(modelID).eachSubProbMedian(is,1) = nanmean(nanmedian(rootfile.(fitops{EM+1}).(modelID){is}.info.prob));
            code = char(rootfile.ID{1,is}.ID);
        end
    catch
    end
    
    rootfile.(fitops{EM+1}).fit.(modelID).allSubProbMedian  = nanmedian(rootfile.(fitops{EM+1}).fit.(modelID).eachSubProbMedian);
    rootfile.(fitops{EM+1}).fit.(modelID).allSubProbMean = nanmean(rootfile.(fitops{EM+1}).fit.(modelID).eachSubProbMean);
    rootfile.(fitops{EM+1}).fit.(modelID).eachSubProbMedianR2  = (rootfile.(fitops{EM+1}).fit.(modelID).eachSubProbMedian).^2;
    rootfile.(fitops{EM+1}).fit.(modelID).eachSubProbMeanR2 = (rootfile.(fitops{EM+1}).fit.(modelID).eachSubProbMean).^2;
    rootfile.(fitops{EM+1}).fit.(modelID).choiceProbMedianR2  = rootfile.(fitops{EM+1}).fit.(modelID).allSubProbMedian^2;
    rootfile.(fitops{EM+1}).fit.(modelID).choiceProbMeanR2 = rootfile.(fitops{EM+1}).fit.(modelID).allSubProbMean^2;

elseif EM == 1
    try
        for is = 1:n_subj
            rootfile.(fitops{EM+1}).(modelID).fit.eachSubProbMean(is,1) = nanmean(nanmean(rootfile.(fitops{EM+1}).(modelID).sub{1,is}.choiceprob));
            rootfile.(fitops{EM+1}).(modelID).fit.eachSubProbMedian(is,1) = nanmean(nanmedian(rootfile.(fitops{EM+1}).(modelID).sub{1,is}.choiceprob));
            code = char(rootfile.ID{1,is}.ID);
        end
    catch
    end
    
    rootfile.(fitops{EM+1}).(modelID).fit.allSubProbMedian  = nanmedian(rootfile.(fitops{EM+1}).(modelID).fit.eachSubProbMedian);
    rootfile.(fitops{EM+1}).(modelID).fit.allSubProbMean = nanmean(rootfile.(fitops{EM+1}).(modelID).fit.eachSubProbMean);
    rootfile.(fitops{EM+1}).(modelID).fit.eachSubProbMedianR2  = (rootfile.(fitops{EM+1}).(modelID).fit.eachSubProbMedian).^2;
    rootfile.(fitops{EM+1}).(modelID).fit.eachSubProbMeanR2 = (rootfile.(fitops{EM+1}).(modelID).fit.eachSubProbMean).^2;
    rootfile.(fitops{EM+1}).(modelID).fit.choiceProbMedianR2  = rootfile.(fitops{EM+1}).(modelID).fit.allSubProbMedian^2;
    rootfile.(fitops{EM+1}).(modelID).fit.choiceProbMeanR2 = rootfile.(fitops{EM+1}).(modelID).fit.allSubProbMean^2;

end


