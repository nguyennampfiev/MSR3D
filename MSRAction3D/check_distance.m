function nof_centroid = check_distance(mij_joint,C)
    score = zeros(1,size(C,1));
    for i=1:size(C,1)
        score(i)  = levenshtein_custom(mij_joint,C(i,:));
    end
    score;
    [~,nof_centroid] = min(score);
end