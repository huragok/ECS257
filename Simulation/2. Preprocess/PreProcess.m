clear all;
close all;
clc;

addpath('../Data','../Functions');
%% 1. Preprocess the RSSI measurement to get the empirical mean and variance of the RSSI at each position
load('../Data/omni_16dbm.mat'); % load the data file
load('../Data/Data.mat');

data.x = zeros(numGroup, 2);
data.meanRssi = zeros(numGroup, 5);
data.covRssi = zeros(5, 5, numGroup);
data.numMeasure = zeros(numGroup, 1);
data.rssiDatabase = cell(numGroup, 1);

for indexGroup = 1:numGroup
    data.x(indexGroup, 1) = measure(indexGroup).x; % 
    data.x(indexGroup, 2) = measure(indexGroup).y;
    data.rssiDatabase{indexGroup} = [measure(indexGroup).up{4};...
                                measure(indexGroup).down{4};...
                                measure(indexGroup).left{4};...
                                measure(indexGroup).right{4}]; % Concatenate all RSSI measurements from 4 directions
    data.numMeasure(indexGroup) = length(data.rssiDatabase{indexGroup}); % Total number of measurements at this position
    data.meanRssi(indexGroup, :) = mean(data.rssiDatabase{indexGroup}); % Mean
    data.covRssi(:, :, indexGroup) = cov(data.rssiDatabase{indexGroup}); % Covariance matrix
end

save('../Data/Data.mat','data');

%% 2. Preprocess the floor plan to get the walking distance between each pair of measurement positions
[data.walkDistance, data.next] = GetWalkDistance(data.x, data.corner, data.wall);
save('../Data/Data.mat','data');
