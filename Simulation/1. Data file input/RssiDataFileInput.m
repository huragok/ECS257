clear all;
close all;
clc;

addpath('../Data','../Functions');
    
%% scan the text data file
fid = fopen('../Data/omni_16dbm.txt');
entry = textscan(fid, '%f %f dev%u8 %s %u8 %f %f %f %f %f %f')';
fclose(fid);

%% save the data to a arrays
numEntry = length(entry{1}); % Total number of measurements
xy = [entry{1},entry{2}]; % The x and y coordinate
device = entry{3}; % The number of the device

direction = uint8(zeros(numEntry, 1));
indexUp = strcmp(entry{4}, 'up');  % 1 indicates up
direction(indexUp) = 1; 
indexDown = strcmp(entry{4}, 'down'); % 2 indicates down
direction(indexDown) = 2;
indexLeft = strcmp(entry{4}, 'left'); % 3 indicates left
direction(indexLeft) = 3;
indexRight = strcmp(entry{4}, 'right'); % 4 indicates right
direction(indexRight) = 4;
indexRight = (indexRight | strcmp(entry{4}, '23')); % There seems to be some 'right' mistakenly typed as '23' in the original data
direction(indexRight) = 4;

tssi = entry{5}; % The tranmitted signal strength indication(dbm)
pkt = entry{6}; % The index number of the packet

rssi = zeros(numEntry, 5); % The received signal strength indication(dbm) of the 5 monitors
rssi(:, 1) = entry{7};
rssi(:, 2) = entry{8};
rssi(:, 3) = entry{9};
rssi(:, 4) = entry{10};
rssi(:, 5) = entry{11};

clear('entry');

%% Group the entries into measurement at each location
epsilon = 1e-2; % if the 2 points are within this distance (m) to each other, they are considered to be a single point
group = zeros(numEntry,1);
xyGroup = xy(1,:);
numGroup = 1;
for indexEntry = 1: numEntry
    flagNewLocation = true;
    for indexGroup = 1:numGroup
        if ((xy(indexEntry, 1) - xyGroup(indexGroup, 1))^2 + (xy(indexEntry, 2) - xyGroup(indexGroup, 2))^2 < epsilon^2)
            group(indexEntry) = indexGroup;
            flagNewLocation = false;
        end
    end
    if flagNewLocation
        xyGroup = [xyGroup; xy(indexEntry, :)];
        numGroup = numGroup + 1;
        group(indexEntry) = numGroup;
    end
end

group = uint8(group);

%% Represent all measurement of each location as a structure
%, 'up', {}, 'down', {}, 'left', {}, 'right', {}
measure = struct('x',{}, 'y', {}, 'up', {}, 'down', {}, 'left', {}, 'right', {});

for indexGroup = 1:numGroup
    measure(indexGroup).x = xyGroup(indexGroup,1);
    measure(indexGroup).y = xyGroup(indexGroup,2);
    
    indexGroupMember = (group == indexGroup);
    
    % Sort all up measurement according to pkt index number
    [measure(indexGroup).up{1},I] = sort(pkt(indexGroupMember & indexUp)); % sort 
    
    deviceUnsorted = device(indexGroupMember & indexUp);
    measure(indexGroup).up{2} = deviceUnsorted(I); % device index number
    
    tssiUnsorted = tssi(indexGroupMember & indexUp);
    measure(indexGroup).up{3} = tssiUnsorted(I); % tssi
    
    rssiUnsorted = rssi(indexGroupMember & indexUp, :);
    measure(indexGroup).up{4} = rssiUnsorted(I, :); % rssi
    
    % Sort all down measurement according to pkt index number
    [measure(indexGroup).down{1},I] = sort(pkt(indexGroupMember & indexDown)); % pkt index number 
    
    deviceUnsorted = device(indexGroupMember & indexDown);
    measure(indexGroup).down{2} = deviceUnsorted(I); % device index number
    
    tssiUnsorted = tssi(indexGroupMember & indexDown);
    measure(indexGroup).down{3} = tssiUnsorted(I); % tssi
    
    rssiUnsorted = rssi(indexGroupMember & indexDown, :);
    measure(indexGroup).down{4} = rssiUnsorted(I, :); % rssi
    
    % Sort all left measurement according to pkt index number
    [measure(indexGroup).left{1},I] = sort(pkt(indexGroupMember & indexLeft)); % pkt index number 
    
    deviceUnsorted = device(indexGroupMember & indexLeft);
    measure(indexGroup).left{2} = deviceUnsorted(I); % device index number
    
    tssiUnsorted = tssi(indexGroupMember & indexLeft);
    measure(indexGroup).left{3} = tssiUnsorted(I); % tssi
    
    rssiUnsorted = rssi(indexGroupMember & indexLeft, :);
    measure(indexGroup).left{4} = rssiUnsorted(I, :); % rssi
    
    % Sort all right measurement according to pkt index number
    [measure(indexGroup).right{1},I] = sort(pkt(indexGroupMember & indexRight)); % pkt index number 
    
    deviceUnsorted = device(indexGroupMember & indexRight);
    measure(indexGroup).right{2} = deviceUnsorted(I); % device index number
    
    tssiUnsorted = tssi(indexGroupMember & indexRight);
    measure(indexGroup).right{3} = tssiUnsorted(I); % tssi
    
    rssiUnsorted = rssi(indexGroupMember & indexRight, :);
    measure(indexGroup).right{4} = rssiUnsorted(I, :); % rssi
end

save('../Data/omni_16dbm.mat', 'measure','numGroup');