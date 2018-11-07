% add some path needed
addpath('./libsvm-3-4.22/matlab')
datadir=('./data');
% select Action Set
action_set='ActionSet3.txt';

% init some variable
nof_joints     = 20;
nof_MIJ_joints = 4;
nof_Action     = 8;
nof_layer      = 3;
overlap        = true;
timevar        = false;

% read data in action set
file = fopen(action_set,'r');
filename = cell(1,1);
h=1;
while ~feof(file)
    filename(h) = textscan(file,'%str\n');
    h =h+1;
end
fclose(file);
% compute length S and get list upper of covariance matrix
length_vecS = nof_MIJ_joints *3;
list_index_matrix= get_upper_index_matrix(length_vecS);

data_train   = [];
label_train  = [];
data_test    = [];
label_test   = [];
% matrix_MIJ_joints =cell(8,1);
matrix_determine_joint =zeros(nof_Action,nof_MIJ_joints);
traningsubjects =[1,3,5,7,9];
% create cell A to save all MIJ from training set
A =cell(20,1);
for i = 1:size(filename,2)
    label_action = getLabelAction(char(filename{i}));
    data = load(fullfile(datadir,[char(filename{i}),'_skeleton3D.txt']));
    [n d] = size(data);
    noframes = n / nof_joints;
    Skeleton.x = reshape(data(:,1), nof_joints, noframes); % x
    Skeleton.y = reshape(data(:,2), nof_joints, noframes); % y
    Skeleton.z = reshape(data(:,3), nof_joints, noframes);
    Skeleton.t = 1:noframes; % 
    if( ~isempty(find(traningsubjects == getSubject(char(filename{i})),1)));
        [list_MIJ_each_action]= most_informative_joints((Skeleton.x)',(Skeleton.y)',(Skeleton.z)',nof_MIJ_joints);
        data_train      = [data_train;Skeleton];
        label_train     = [label_train;label_action];
        A{label_action} = [A{label_action};list_MIJ_each_action'];
    else
        data_test = [data_test;Skeleton];
        label_test = [label_test;label_action];
    end
end
unique_label_train = unique(label_train);
% determine MIJ for each action
for k=1:length(unique_label_train)
    matrix_determine_joint(k,:) = getIdxMostJoints(A{unique_label_train(k)},nof_MIJ_joints);
end
models = cell(nof_Action,1);
fprintf('training \n');
for model=1:length(models)
    feature_train =[];
    for i =1:size(data_train,1)
    %load data train
        X = (data_train(i).x)';
        Y = (data_train(i).y)';
        Z = (data_train(i).z)';
        list_real_idx_joint = matrix_determine_joint(model,:);
        Xnew = X(:,sort(list_real_idx_joint));
        Ynew = Y(:,sort(list_real_idx_joint));
        Znew = Z(:,sort(list_real_idx_joint));
        t= data_train(i).t;
        cov_matrix = covariance_features_for_root(Xnew, Ynew, Znew, t', nof_layer,overlap,list_index_matrix);
        % covariance skeleton
        concatcate_cov_to_vec = cell2mat(cellfun(@(x)(cell2mat(x)), reshape(cov_matrix, 1, []), 'UniformOutput', false));
        feature_train = [feature_train;concatcate_cov_to_vec];
    end
    models{model} = svmtrain(double(label_train==unique_label_train(model)), feature_train, '-c 10 -g 1 -b 1 -q');
    fprintf('Done model %d \n',model);
end
fprintf('testing \n');
prob = zeros(length(label_test),length(unique_label_train)); 
for model=1:length(models)
    feature_test =[];
    for i =1:size(data_test,1)
        X     = (data_test(i).x)';
        Y     = (data_test(i).y)';
        Z     = (data_test(i).z)';
        
        list_real_idx_joint = matrix_determine_joint(model,:);
        Xnew  = X(:,sort(list_real_idx_joint));
        Ynew  = Y(:,sort(list_real_idx_joint));
        Znew  = Z(:,sort(list_real_idx_joint));
        t =data_test(i).t;
        
        % covariance skeleton
        cov_matrix = covariance_features_for_root(Xnew, Ynew, Znew, t', nof_layer,overlap,list_index_matrix);
        concatcate_cov_to_vec = cell2mat(cellfun(@(x)(cell2mat(x)), reshape(cov_matrix, 1, []), 'UniformOutput', false));
        feature_test = [feature_test;concatcate_cov_to_vec];
    end
    [predict_label, accuracy, prob_estimates] = svmpredict(double(label_test==unique_label_train(model)), feature_test, models{model}, '-b 1 -q');
     prob(:,model)                             = prob_estimates(:,models{model}.Label==1); 
end
[~,predict] = max(prob,[],2);
for j = 1 : numel(predict)
    predict(j) = unique_label_train(predict(j));
end
fprintf('Accuracy :')
acc = sum(predict == label_test) ./ numel(label_test);