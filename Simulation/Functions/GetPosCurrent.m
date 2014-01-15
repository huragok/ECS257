function [indexPosCurrent, costViterbi, routeViterbi] = GetPosCurrent(rssi, speed, meanRssi, covRssi, walkDistance, Ts, p, k, costViterbi, routeViterbi)
% Iteraively called to update the k cost and optimum routes in Viterbi-like
% algorithm, and return the best estimation of current position
% Output:
% indexPosCurrent: the index of the estimated current position
% costViterbi: the updated k * 1 cost vector
% routeViterbi: the updated k * (n + 1) route matrix
% Input:
% rssi: latest observed RSSI
% speed: latest observed speed
% meanRssi: mean RSSI at all measurement positions
% covRssi: covariance of RSSI at all measurement positions
% walkDistance: used in the calculation of the transition probability
% Ts: the sampling period
% p: Perturbation parameter used in the calculation of transition
%    probability, the smaller p, the more this transition probability is 
%    trusted 
% k: coarsely choose k positions with mean RSSI closest to the observed 
%    RSSI as possible positions
% costViterbi: the k * 1 current cost vector
% routeViterbi: the current k * n route matrix

indexPoskNear = GetkNear(rssi, meanRssi, k); % Coarsely find the k possible positions according to the first observation
n = size(routeViterbi, 2);
routeViterbiUpdate = zeros(k, n+1);
probTrans = zeros(k, k); % Transition probability matrix, need to be dynamically updated according to the current speed
for indexkLast = 1 : k % Update the transition probability matrix
    for indexk = 1 : k
        probTrans(indexkLast, indexk) = exp(-(walkDistance(routeViterbi(indexkLast,end), indexPoskNear(indexk)) - speed * Ts) ^ 2 / (speed * Ts + p) ^ 2);
    end
    probTrans(indexkLast, :) = probTrans(indexkLast, :) / sum(probTrans(indexkLast, :));
end
    
for indexk = 1:k % Current position
    costTemp = zeros(k, 1); % The cost for the transition between all last positions to the current position
    costObservation = GetDeltaLLR(rssi, meanRssi(indexPoskNear(indexk), :), covRssi(:, :, indexPoskNear(indexk))); % Cost increment from observation
    for indexkLast = 1:k % Last position         
        costTemp(indexkLast) = costViterbi(indexkLast) + costObservation - log(probTrans(indexkLast, indexk)); % cost increment from transition probability
    end
    [costViterbi(indexk), indexkLastMin] = min(costTemp); % find the route with the minimum total cost, selected as the optimum route ending at the current position
    routeViterbiUpdate(indexk, :) =  [routeViterbi(indexkLastMin, :), indexPoskNear(indexk)]; % record the corresponding route
end
    
routeViterbi = routeViterbiUpdate; % Update the k optimum routes
[~, indexkCostMin] = min(costViterbi);
indexPosCurrent = routeViterbi(indexkCostMin, end);

end

