function normx = normCor(cord)
% normalize coordinate 
    minX = min(cord(:));
    maxX = max(cord(:));
    normx = (cord - minX) / (maxX - minX);
    end