function normt = normSeT(T)
    % normalize Time similar with coordinate
    minT = min(T(:));
    maxT = max(T(:));
    normt = (T - minT) / (maxT - minT + 1e-5);
end