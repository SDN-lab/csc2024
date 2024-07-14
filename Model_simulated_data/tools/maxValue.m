function [maxK] = maxValue(rootfile, modelID)

% Get maximum values (parameter upper bounds) for parameters:
% k - effort discounting
% rew - reward sensitivity
% input "param" must match one of the above paramter names

% Jo Cutler March 2022

minEffort = min(rootfile.effort); % minimum effort level
maxEffort = max(rootfile.effort); % maximum effort level
minReward = min(rootfile.reward); % minimum reward level
maxReward = max(rootfile.reward); % maximum reward level

% maximum k calculated as the discount rate that means the
% maximum reward and minimum effort has a value of 'low'
low = 0;
maxKp = (maxReward - low) ./ (minEffort.^2); % parabolic
maxKl = (maxReward - low) ./ (minEffort); % linear
maxKh = ((maxReward * (1/low)) - 1) / minEffort; % hyperbolic
if maxKh == Inf
    maxKh = max(maxKp, maxKl);
end

if contains(modelID, 'all')
    maxK = round(max([maxKl, maxKh, maxKp]), 2);
elseif contains(modelID, 'linear')
    maxK = round(maxKl,2);
elseif contains(modelID, 'hyperbolic')
    maxK = round(maxKh,2);
else
    maxK = round(maxKp,2);
end

end

