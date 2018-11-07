function listIdx = getIdxMostJoints(matrixJoints,onf)
% determine MIJ  final for each action from matrix MIJ 
% Input matrix MIJ,number of MIJ want to select on each action 
    listAngle = unique(matrixJoints);
    listValueAngle = zeros(1,size(listAngle,1));
    for a=1:size(listAngle,1)
        listValueAngle(a) = sum(sum(matrixJoints ==listAngle(a)));
    end
    [val ind] = sort(listValueAngle,'descend');
    listIndex = ind(1:onf);
    listIdx = listAngle(listIndex);

end