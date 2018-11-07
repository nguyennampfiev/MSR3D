function list_angular_joints = compute_angular_joints(X)
nof_frame= size(X,1);
list_angular_joints =zeros(size(X));
    for i=2:nof_frame-1
        list_angular_joints(i,:) = X(i+1,:) -X(i-1,:);
    end
    list_angular_joints(1,:) = 0;
    list_angular_joints(nof_frame,:) = X(nof_frame-1,:)-X(nof_frame,:);
end