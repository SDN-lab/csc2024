function [f] = all_real(p, chosen, effort, reward, agent, model)% same as in models above in same order

%%%%% 1. Assign free parameters and other stuff:

discount = (agent==1).*p(1) + (agent==2).*p(2);

if contains(model, 'one_beta')
    beta = p(3);
elseif contains(model, 'two_beta')
    beta = (agent==1).*p(3) + (agent==2).*p(4);
end

base = 1;

%%%% Devalue reward by effort

if contains(model, 'linear')
    val = reward - (discount.*(effort));
elseif contains(model, 'hyperbolic')
    val = reward ./ (1 + (discount.*(effort)));
else
    val = reward - (discount.*(effort.^2));
end

%%%% Apply softmax to calculate probability of choosing work

prob =  exp(val.*beta)./(exp(base*beta) + exp(beta.*val));

%%%% Get probability of choosing what they actually chose (work or rest)

prob(~chosen) =  1 - prob(~chosen);

% calculate neg-log-likelihood
f=-nansum(log(prob));

end