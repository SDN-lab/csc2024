function [fval,fit] = mod_ms_all(behavData, q, fitop, modelID, bounds, varargin)

% runs standard Prosocial motivation disocunt model
% P Lockwood modified 1 July 2019 from MK Wittmann, Oct 2018
%
% INPUT:    - behavData: behavioural input file
% OUTPUT:   - fval and fitted variables
%

%%
% -------------------------------------------------------------------------------------
% 1 ) Define free parameters
% -------------------------------------------------------------------------------------

if nargin > 5
    prior      = varargin{1};
end

params = get_params(['ms_', modelID]);

for p = 1:length(params)
    
    qt(p) = norm2positive(q(p), [bounds.lower(p), bounds.upper(p)]); % transform parameters from gaussian space to model space
    
end

all_prob = [];
all_V  = [];

%%% 0.) Load information for that subject:    % load in each subjects variables for the experiment
chosen   = behavData.choice';
effort   = behavData.effort';
reward   = behavData.reward';
agent    = behavData.agent';

indmiss2=chosen==2;
indmiss=isnan(chosen);
indmiss = (indmiss + indmiss2) > 0;
chosen(indmiss) = [];
effort(indmiss) = [];
reward(indmiss) = [];
agent(indmiss)  = [];

% Define free parameters

if contains(modelID, 'one_k')
    discount = qt(1);
    beta1 = 2;
elseif contains(modelID, 'two_k')
    discount = (agent==1).*qt(1) + (agent==2).*qt(2);
    beta1 = 3;
elseif ~contains(modelID, 'k')
    discount = [];
    beta1 = 1;
else
    error(['Cant`t determine number of k parameters from model name: ', modelID])
end

if contains(modelID, 'one_beta')
    beta = qt(beta1);
elseif contains(modelID, 'two_beta')
    beta = (agent==1).*qt(beta1) + (agent==2).*qt(beta1+1);
else
    error(['Cant`t determine number of beta parameters from model name: ', modelID])
end

base = 1;
   
%%%% Model - devalue reward by effort
    
if contains(modelID, 'linear')
    val = reward - (discount.*(effort));
elseif contains(modelID, 'hyperbolic')
    val = reward ./ (1 + (discount.*(effort)));
else
    if contains(modelID, 'beta_')
        error(['Detection of model as linear / hyperbolic / neither may not be correct for model ', modelID])
    else
        val = reward - (discount.*(effort.^2));
    end
end
    
prob =  exp(val.*beta)./(exp(base*beta) + exp(beta.*val));
prob(~chosen) =  1 - prob(~chosen);
[r, c] = size(prob);
if r>c
prob = prob(:,1);
else
prob = prob(1,:);
end

if max(size(prob)) == 1
    error('Variable prob should have as many rows as trials - check above')
end

%%% 4. now save stuff:
all_V      =  val;
all_prob   =  prob;


% all choice probablities
ChoiceProb=all_prob';

% -------------------------------------------------------------------------------------
% 4 ) Calculate model fit:
% -------------------------------------------------------------------------------------

nll =-nansum(log(ChoiceProb));                                              % the thing to minimize

if nll == Inf
    nll = realmax;
else
end

if fitop.doprior == 0                                                               % NLL fit
    fval = nll;
elseif fitop.doprior == 1                                                           % EM-fit:   P(Choices | h) * P(h | O) should be maximised, therefore same as minimizing it with negative sign
    fval = -(-nll + prior.logpdf(q));
end

% % make sure f is not just low because of Nans in prob-variable:

sumofnans=sum(sum(isnan(chosen)));
if sum(isnan(ChoiceProb))~=sumofnans
    disp('ERROR NaNs in choice and choice prob dont agree');
    keyboard;
    return;
end

% -------------------------------------------------------------------------------------
% 5) Calculate additional Parameters and save:
% -------------------------------------------------------------------------------------

if fitop.dofit ==1
    
    fit         = struct;
    fit.xnames  = params;
    
    fit.choiceprob = [ChoiceProb];
    fit.mat    = [all_V];
    fit.names  = {'V'};
    
end

end
