function invDeltaLLR = GetDeltaLLR(x, mean, cov)
% Return the inverse of the increment of the log likelihood ratio for 
% Gaussian distribution (not including the constant term). Suffice to 
% handle the situation where some elements is not random (i.e. the diagonal
% elements of cov is zero. x, mean are both row vectors
indexRV = find(diag(cov));

xRV = x(indexRV);
meanRV =mean(indexRV);
covRV = cov(indexRV, indexRV);

invDeltaLLR = 1 / 2 * ((xRV - meanRV) * (covRV \ (xRV - meanRV)') + log(det(covRV))); % Cost increment from observation