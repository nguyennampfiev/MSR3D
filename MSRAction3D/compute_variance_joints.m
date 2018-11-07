function value_variance = compute_variance_joints(list_value_joints)
%     Compute variance each joint in each action
    mean_value_joints =mean(list_value_joints);
    value_variance =0;
    for i =1:size(list_value_joints,1)
        value_variance = value_variance + sqrt(sum((list_value_joints(i,:)-mean_value_joints).^2));
    end
    value_variance =value_variance/(size(list_value_joints,1)-1);
end