function [path_min,dist_min] = viterbi_like(xy_coor,k,h)

path = zeros(k,h);
path(:,1) = [1:1:k]';
dist = zeros(k,h);
temp = zeros(k,1);

% Note: xy_coor needs two columns to reprsent one coordinate

for i = 1:k
    for j = 1:h-1
        for m = 1:k
            temp(m) = norm(xy_coor(path(i,j),2*j-1:2*j)-xy_coor(m,2*(j+1)-1:2*(j+1)));
            [dist(i,j+1),path(i,j+1)] = min(temp);
        end
    end
end

[dist_min,index_min] = min(sum(dist,2));
path_min = path(index_min,:);

end