function routeModified = ModifyRoute(route, next, w)
% Given a user defined route, modify this route so that there is a LOS path
% between two neighboring positions

numPos = length(route);
routeModified = route(1);
for indexPos = 1 : numPos - 1
    routeModified = [routeModified, ReconPath(route(indexPos), route(indexPos + 1), next, w), route(indexPos + 1)];
end

