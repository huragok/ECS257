clear all;
close all;
clc;

addpath('../Data','../Functions');
load('../Data/Data.mat');

%% Creat the weighted adjacency matrix
numPos = length(data.x); % Number of positions measured in this experiment
seqPos = (1:numPos)'; % Sequence of the positions
rMax = 30; % If two points is at least rMax meter apart from each other, their spatial proximity is 0
varX = sum(var(data.x)); % variance of the spatial proximity for all positions
varI = sum(var(data.meanRssi));  % variance of the received signal strength index

data.W = zeros(numPos, numPos); % The weighted adjacency matrix
for indexI = 1:numPos
    data.W(indexI, indexI) = 1; % The value of the diagonal element really doesn't matter
    for indexJ = indexI + 1 : numPos
        if (norm(data.x(indexI) - data.x(indexJ)) < rMax)
            w = exp((-norm(data.x(indexI, :) - data.x(indexJ, :)) ^ 2) / varX)...
              * exp((-norm(data.meanRssi(indexI, :) - data.meanRssi(indexJ, :)) ^ 2) / varI); % spatial proximity times RSSI proximity
            data.W(indexI, indexJ) = w;
            data.W(indexJ, indexI) = w;
        end
    end
end

save('../Data/Data.mat', 'data');
%% Perform the normalized graph partitioning algorithm
posCluster = BiPartition(data.W, 0.6);
numCluster = size(posCluster, 1);

posSorted = [];
for indexCluster = 1:numCluster
    posSorted = [posSorted,posCluster{indexCluster}];
end
WClustered = data.W(posSorted, posSorted);

figure;
numPos = size(data.W, 1);
imagesc(WClustered), hold on;
bound = 1;
for indexCluster = 1:numCluster
    plot(bound*ones(1, numPos), 1:numPos, 'k', 'linewidth', 3);
    plot(1:numPos, bound *ones(1, numPos), 'k', 'linewidth', 3);
    bound = bound + length(posCluster{indexCluster});
end
axis equal, xlim([1, numPos]),ylim([1, numPos]), colorbar, set(gca,'FontSize',14);


figure;

cmap=colormap(hsv(numCluster));
for indexCluster = 1:numCluster
    xTemp = data.x(posCluster{indexCluster},:);
    yFloorPlan = xTemp(:,1);
    xFloorPlan = 75 - xTemp(:,2);
    plot(xFloorPlan, yFloorPlan, '+', 'Color',cmap(indexCluster,:), 'linewidth', 3), hold on;
    
end
legendItem = cell(numCluster, 1);
for indexCluster = 1:numCluster
    legendItem{indexCluster} = ['Cluster',num2str(indexCluster)];
end
legend(legendItem);

numWall = size(data.wall, 1);
for indexWall = 1:numWall
    plot(75 - data.corner(data.wall(indexWall, :), 2), ...
         data.corner(data.wall(indexWall, :), 1), ...
         'k-', 'linewidth', 2);
end

text(50,2.5,'\uparrow M1','VerticalAlignment','bottom','FontSize',14);
text(64,43,'\uparrow M2','VerticalAlignment','bottom','FontSize',14);
text(35,16,'\uparrow M3','VerticalAlignment','bottom','FontSize',14);
text(53,17,'\uparrow M4','VerticalAlignment','bottom','FontSize',14);
text(25,29,'\uparrow M5','VerticalAlignment','bottom','FontSize',14);
    
grid on, xlim([0,70]), ylim([0,50]), set(gca,'FontSize',14), axis equal;
xlabel('y', 'fontsize', 14), ylabel('x', 'fontsize', 14);

