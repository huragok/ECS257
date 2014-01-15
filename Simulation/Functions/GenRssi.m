function rssi = GenRssi(indexPosNeighbor, weight, rssiDatabase)

numPos = length(indexPosNeighbor);

rssiRandSel = zeros(numPos, 5);
for indexPos = 1:numPos
    numEntry = length(rssiDatabase{indexPosNeighbor(indexPos)});
    indexEntry = randi(numEntry, 1, 1);
    rssiRandSel(indexPos, :) = rssiDatabase{indexPosNeighbor(indexPos)}(indexEntry, :);
end

rssi = weight' * rssiRandSel;
