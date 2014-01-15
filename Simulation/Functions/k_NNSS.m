function xy = k_NNSS(k,numGroup,measure,Rssi_true)

% ----------------------------------------------
% Input
% k: number of neighbors for interpolation 
% numGroup: 
% measure:
% Rssi_true: 
%
% Output
% xy: k nearest coordinates
% ----------------------------------------------

%% Preprocess data

mean_Rssi = zeros(numGroup,5,4); % mean RSSI at each location and each direction

for indexGroup = 1:numGroup
    
    % mean RSSI at each location and each direction
    mean_Rssi(indexGroup,:,1) = mean(measure(indexGroup).up{4});    % up=1
    mean_Rssi(indexGroup,:,2) = mean(measure(indexGroup).down{4});  % down=2
    mean_Rssi(indexGroup,:,3) = mean(measure(indexGroup).left{4});  % left=3
    mean_Rssi(indexGroup,:,4) = mean(measure(indexGroup).right{4}); % right=4
    
end

%% meanRssi -- interpolation using k neighbors.
%  At each location, seach among all the directions to estimate the
%  location; multiple nearest neighbors may correspond to different
%  directions at the same point in physical space.

loc_dir = zeros(numGroup,4);  % location-direction matrix 
for i = 1:numGroup
    for j = 1:4
    % each entry is the distance between Rssi measurement and Rssi fingerprints
        loc_dir(i,j) = norm(mean_Rssi(i,:,j)-Rssi_true);
    end
end

% based on the paper
loc_dir_vec = loc_dir(:);  % vectorize
[~,loc_dir_sort] = sort(loc_dir_vec);  % sort distance ascendingly
interpolation = mod((loc_dir_sort(1:k)),ones(k,1)*numGroup); 
for j = 1:k
    if interpolation(j) == 0
        interpolation(j) = interpolation(j)+numGroup;
    end
end
xy = zeros(k,2);
for i = 1:k
    xy(i,:) = [measure(interpolation(i)).x,measure(interpolation(i)).y];
end

end
