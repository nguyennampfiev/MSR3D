function listValue = getValueMatrix(sizeMatrix)
% get the list index upper or lower of covariance matrix
    maTrixLength = sizeMatrix * (sizeMatrix + 1) / 2; 
    getmaTrixIndex = zeros(1, maTrixLength);
    starts = 1;
    id1 = 1;
    for i = 1:sizeMatrix
        delta = sizeMatrix - i;
        id2 = id1 + delta; 
        getmaTrixIndex(id1:id2) = starts:(starts + delta);
        id1 = id2 + 1;
        starts = starts + sizeMatrix + 1;
    end
   listValue = getmaTrixIndex; 
end