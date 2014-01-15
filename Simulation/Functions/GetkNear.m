function indexPoskNear = GetkNear(rssi, meanRssi, k)
% Returning index of the k measurment positions with meanRssi closest to
% rssi
% Output:
% indexPoskNear: The index of the  k nearest measurement positions
% Input:
% rssi: Observed RSSI
% meanRssi: mean RSSI for all measurement points

numPos = size(meanRssi, 1);
distRssi = zeros(numPos, 1);
for indexPos = 1: numPos
    distRssi(indexPos) = norm(rssi - meanRssi(indexPos, :));
end

[~,indexPosSorted] = sort(distRssi);
indexPoskNear = indexPosSorted(1:k);

end
