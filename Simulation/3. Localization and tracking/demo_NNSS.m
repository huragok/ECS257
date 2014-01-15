close all;

for ii = 1:5

clear all;
clc;
addpath('../Data','../Functions');
%addpath(genpath('/Users/Kun/Documents/MATLAB/ECS257 RADAR'),...
  %  genpath('/Users/Kun/Documents/MATLAB/ECS257 Project'));

load ../Data/Data.mat
load ../Data/omni_16dbm;

% generate a random position

while (1)
location_1 = randi(numGroup);
location_2 = randi(numGroup);
if ~data.next(location_1,location_2)
    break;
end
end
xy_true1 = data.x(location_1,:);
xy_true2 = data.x(location_2,:);
xy_true = 0.5*(xy_true1+xy_true2);

% generate cooresponding rssi
[indexPosNeighbor,weight] = FindPosNeighbor(xy_true,3,data.x,data.corner,data.wall,0.1); 
Rssi_true = GenRssi(indexPosNeighbor,weight,data.rssiDatabase);


k = 3;   % k neareat neighbors
xy = k_NNSS(k,numGroup,measure,Rssi_true);
xy_NNSS = xy(1,:);
err1 = norm(xy_NNSS-xy_true);
xy_k_NNSS = mean(xy,1);
err2 = norm(xy_k_NNSS-xy_true);

cla;
PlotFloorPlan(data.wall,data.corner,data.x,0)
plot(75-xy_true(2),xy_true(1),'ro','linewidth',3);
plot(75-xy_NNSS(2),xy_NNSS(1),'b*','linewidth',3);
plot(75-xy_k_NNSS(2),xy_k_NNSS(1),'m^','linewidth',3);
axis([0 70 0 50]);
pause

end

close all;
