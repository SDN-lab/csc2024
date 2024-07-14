function [params] = get_params( modelID)
% Lookup table to get number of free parameters per model
% MKW 2018

if contains(modelID, 'one_k')
    kparams = {'k'};
elseif contains(modelID, 'two_k')
    kparams = {'k_food', 'k_climate'};
elseif ~contains(modelID, 'k')
    kparams = {};
else
    error(['Cant`t determine number of k parameters from model name: ', modelID])
end
    
if contains(modelID, 'one_beta')
    betaparams = {'beta'};
elseif contains(modelID, 'two_beta')
    betaparams = {'beta_food', 'beta_climate'};
else
    error(['Cant`t determine number of beta parameters from model name: ', modelID])
end
    
params = [kparams, betaparams];

end

