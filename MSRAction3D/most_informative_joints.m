function  [list_MIJ_each_action,list_MIJ_binary] = most_informative_joints(X,Y,Z,nof_MIJ_joints)
% compute the Most Informative Joints from each sample 
% Input X,Y,Z,number of Most Infomative Joints
% size(X,1) number of frames, size(X,2) number of joints(full)
% Output list_MIJ_each_action the most infomative joints of sample  
        
    nof_joints = size(X,2);
    nof_frames = size(X,1);
    assert(size(Y, 2) == nof_joints);
    assert(size(Z, 2) == nof_joints);
    assert(size(Y, 1) == nof_frames);
    assert(size(Z, 1) == nof_frames);
    list_value_variance_joints = zeros(nof_joints,1);
    list_MIJ_binary = zeros(nof_joints,1);
    for i=1:nof_joints
        list_value_joint =zeros(nof_frames,3);
        for j=1:nof_frames
            list_value_joint(j,:) = [X(j,i),Y(j,i),Z(j,i)];
        end

        list_value_variance_joints(i)= compute_variance_joints(list_value_joint);
    end
    [~, ind] = sort(list_value_variance_joints,'descend');
    list_MIJ_each_action = ind(1:nof_MIJ_joints);
    list_MIJ_binary(list_MIJ_each_action) =1;
end