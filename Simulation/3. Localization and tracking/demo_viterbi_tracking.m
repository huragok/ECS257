clear all;
close all;
clc;

addpath('../Data','../Functions');
%addpath(genpath('/Users/Kun/Documents/MATLAB/ECS257 RADAR'),...
 %   genpath('/Users/Kun/Documents/MATLAB/ECS257 Project'));

load ../Data/Data.mat
load ../Data/omni_16dbm.mat

% load omni_16dbm.mat
% load RssiData.mat
% load FloorPlan.mat
% load Graph.mat

route = [82,92,104,115,126,140,161,171,179,6,23,37,47,46,45,44,43];

% route = [20,17,14,11,8,24,23,179,161,126,104,82];

% generate xy coordinates
% route = [20,19,18,17,16,15,14,13,12,11,10,9,8,7,24,23,6,179,171,161,140,126,115,104,92,82];
% route = [20,18,16,14,12,10,8,24,23,179,161,126,104,82];
%route = [20,17,14,11,8,24,23,179,161,126,104,82];
% route = [20,16,11,7,23,171,126,104,82];
speedProfile = GenSpeedProfile(route, [1, 5], 1, data.walkDistance);
[xSample, speedSample, tSample] = GenRouteSample(route, speedProfile, 1, data.walkDistance, data.x);

L = length(xSample);
% generate cooresponding rssi
Rssi_true = zeros(L,5);
for i = 1:L
    [indexPosNeighbor,weight] = FindPosNeighbor(xSample(i,:),3,data.x,data.corner,data.wall,0.1); 
    Rssi_true(i,:) = GenRssi(indexPosNeighbor,weight,data.rssiDatabase);
end

k = 3;  % k nearest neighbors
h = 6;  % memory length

xy_coor = zeros(k,2*L);
for j = 1:L
    % xy is k-by-2 matrix; xy_true is 1-by-2 vector
    xy_coor(:,2*j-1:2*j) = k_NNSS(k,numGroup,measure,Rssi_true(j,:));
end


xy_est_viterbi = zeros(L, 2);
for i = 1 : L - h + 1
     xy_nei = xy_coor(:, 2 * i - 1 : 2 * i + 2 * h - 2);
     [path_min,dist_min] = viterbi_like(xy_nei,k,h);
     xy_est_viterbi(i, :) = xy_nei(path_min(1), 1:2);
end

for i = L - h + 2: L
    xy_est_viterbi(i, :) = xy_nei(path_min(1), (1:2) + 2 * (i - L + h - 1));
end


% % Viterbi-like algorithm
% [path_min,dist_min] = viterbi_like(xy_coor,k,h);
% xy_est_viterbi = xy_coor(path_min(1),1:2)

figure;
PlotFloorPlan(data.wall,data.corner,data.x,0);

plot(75 - xSample(1, 2), xSample(1, 1), 'ro','linewidth',2);
plot(75 - xy_est_viterbi(1, 2), xy_est_viterbi(1, 1), 'bo','linewidth',2);
    
pause

for i = 1 : L-1
    plot(75 - [xSample(i, 2), xSample(i+1, 2)], [xSample(i, 1), xSample(i+1, 1)], 'ro--','linewidth',2);
    plot(75 - [xy_est_viterbi(i, 2), xy_est_viterbi(i+1, 2)], [xy_est_viterbi(i, 1), xy_est_viterbi(i+1, 1)], 'bo--','linewidth',2);
    
    pause
    
end
    
close all;
