function vertexCluster = BiPartition(W, NcutMax)
% Recurcively compute graph spectral bipartition according to a weighted 
% adjacency matrix  W, when the Ncut is greater than NcutMax, stop. Return
% a cell array where each element is an array contains all vertices
% corresponding to a single cluster

numVertex = size(W, 1); % number of points in the graph
Vertex = 1:numVertex;

D = diag(sum(W)); % Degree matrix
L = D - W; % Laplacian matrix
[V, ~] = eig((D^-0.5)*L*(D^-0.5)); % Eigendecomposition of the normalized Laplacian
[~, indexSort] = sort(V(:,2)); % Sort the eigenvector corresponding to the second smallest eigenvalue
WSorted = W(indexSort, indexSort); % The weighted adjacency matrix corresponding to the sorted positions
Dsorted = diag(D(indexSort, indexSort)); % The degree matrix corresponding to the sorted positions
vertexSorted = Vertex(indexSort); % The sequential number of the sorted positions

Ncut = zeros(numVertex-1, 1); 
for indexPos = 2:numVertex % Search for the splitting point that can minimize Ncut
    Ncut(indexPos-1) = sum(sum(WSorted(indexPos:numVertex, 1:indexPos-1))) * (1 / (sum(Dsorted(1:indexPos-1))) + 1 / (sum(Dsorted(indexPos:numVertex))));
end
[~, indexMinNcut] = min(Ncut);
indexMinNcut = indexMinNcut + 1;

if Ncut > NcutMax % the partition is over-complete, so no partition is performed at this step
    vertexCluster = {Vertex};
    return;
else % the partition may not be complete yet, so the 2 partitioned part may need to be further partitioned
    vertexLU = vertexSorted(1:indexMinNcut-1); % The left-up part of vertices
    vertexRD = vertexSorted(indexMinNcut:numVertex); % The right-down part of vertices

    vertexClusterLU = BiPartition(W(vertexLU, vertexLU), NcutMax); % Recursively call BiPartition function to cluster the left-up part of vertices
    vertexClusterRD = BiPartition(W(vertexRD, vertexRD), NcutMax); % cluster the right-down part of vertices
    numClusterLU = size(vertexClusterLU, 1);
    numClusterRD = size(vertexClusterRD, 1);
    
    vertexCluster = cell(numClusterLU + numClusterRD, 1); % Now we can combine these two clusters of vertices
    for indexCluster = 1 : numClusterLU
        vertexCluster{indexCluster} = vertexLU(vertexClusterLU{indexCluster});
    end
    for indexCluster = 1 : numClusterRD
        vertexCluster{indexCluster + numClusterLU} = vertexRD(vertexClusterRD{indexCluster});
    end
    
    return;
end
    