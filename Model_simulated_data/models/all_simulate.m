function [chosen] = all_simulate(effort, reward, agent, p, model)% same as in models above in same order

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

%%%% Create simulated choices of work over rest offer
% generate random numbers betwee 0-1 and make
% chosen = 1 if probability higher than this or
% chosen = 0 if lower than random number

for t = 1:length(prob)
    chosen(t,1) = double(rand < (prob(t)));
end

end
