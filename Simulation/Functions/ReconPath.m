function path = ReconPath(indexSrc, indexDest, next, w)
    if isinf(w(indexSrc, indexDest))
        error('No path!');
    end
    indexVia = next(indexSrc, indexDest);
    if indexVia == 0
        path = [];
    else
        path = [ReconPath(indexSrc, indexVia, next, w), indexVia, ReconPath(indexVia, indexDest, next, w)];
    end
end