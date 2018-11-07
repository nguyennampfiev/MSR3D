function list_index_upper = get_upper_index_matrix(length_vecS)
%     Get list index upper or lower of covariance matrix
    size_matrix = length_vecS * (length_vecS + 1) / 2; 
    list_index_upper = zeros(1, size_matrix);
    starts = 1;
    id1 = 1;
    for i = 1:length_vecS
        delta = length_vecS - i;
        id2 = id1 + delta; 
        list_index_upper(id1:id2) = starts:(starts + delta);
        id1 = id2 + 1;
        starts = starts + length_vecS + 1;
    end 
end