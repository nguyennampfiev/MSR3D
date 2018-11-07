addpath('./libsvm-3-4.22/matlab')
datadir=('./data');
addpath('./MostJoint')
addpath('../A')
action_set='ActionSet3.txt';
nof_joints=20;
nof_MIJ_joints =6;
nof_centroid =2;
nof_Action =8;
nof_layer =3;
overlap =true;
timevar =false;
% actionName = {'Wave','Hammer','Smash','Catch','Forward Punch','Throw','Draw X','Draw Tick','Draw Circle','Clapping Hand','Two hand Wave','Side Boxing','Bend','Forward Kick','Side Kick','Jogging','Tennis Swing','Tennis Serve','Golf Swing','Pickup&throw'};
file = fopen(action_set,'r');
filename = cell(1,1);
h=1;
while ~feof(file)
    filename(h) = textscan(file,'%str\n');
    h =h+1;
end
fclose(file);
% length_vecS = nof_MIJ_joints *3;
% list_index_matrix= get_upper_index_matrix(length_vecS);
data_train =[];
label_train  = [];
data_test =[];
label_test =[];
% matrix_MIJ_joints =cell(8,1);
matrix_determine_joint =zeros(nof_Action,nof_MIJ_joints);
traningsubjects =[1,3,5,7,9];
matrix_MIJ_binary =[];
% matrix_MIJ_index=[];
A =cell(20,1);
for i = 1:size(filename,2)
    label_action = getLabelAction(char(filename{i}));
    data = load(fullfile(datadir,[char(filename{i}),'_skeleton3D.txt']));
    [n d] = size(data);
    noframes = n / nof_joints;
    Skeleton.x = reshape(data(:,1), nof_joints, noframes); % x
    Skeleton.y = reshape(data(:,2), nof_joints, noframes); % y
    Skeleton.z = reshape(data(:,3), nof_joints, noframes);
    Skeleton.t = 1:noframes; % z
    if( ~isempty(find(traningsubjects == getSubject(char(filename{i})),1)));
        [list_MIJ_each_action]= getMostJoints((Skeleton.x)',(Skeleton.y)',(Skeleton.z)',1,nof_MIJ_joints);
%         list_MIJ_each_action = getMostJoints(Skeleton.x,Skeleton.y,Skeleton.z,1,nof_MIJ_joints)
%         pause
        data_train = [data_train;Skeleton];
        label_train = [label_train;label_action];
        A{label_action} = [A{label_action};list_MIJ_each_action'];
    else
        data_test = [data_test;Skeleton];
        label_test = [label_test;label_action];
    end
end
G = unique(label_train);
for k=1:length(G)
    matrix_determine_joint(k,:) = getIdxMostJoints(A{G(k)},nof_MIJ_joints);
end
matrix_determine_joint;
matrix_covariance=zeros(size(matrix_determine_joint,1));
for i =1:size(matrix_determine_joint,1)
    for j=1 :size(matrix_determine_joint,1)
    matrix_covariance(i,j)= levenshtein_custom(matrix_determine_joint(i,:),matrix_determine_joint(j,:));
    end
end
Z = linkage(matrix_covariance);
dendrogram(Z)
T = cluster(Z,'maxclust',nof_centroid)
% pause
new_matrix_determine_joint= cell(nof_centroid,1);
for i=1:nof_centroid
    new_matrix_determine_joint{i} =reshape(unique(matrix_determine_joint(T==i,:)),1,[]);
end
feature_train=cell(nof_centroid,1);
label_centroid_train =cell(nof_centroid,1);
model =cell(nof_centroid,1);
fprintf('training \n');
list_clustering=[];
for i =1:size(data_train,1)
        X = (data_train(i).x)';
        Y = (data_train(i).y)';
        Z = (data_train(i).z)';
        list_MIJ_each_action= getMostJoints(X,Y,Z,1,nof_MIJ_joints);
        list_joint =T(G==label_train(i));
        list_real_idx_joint= new_matrix_determine_joint{list_joint};
        Xnew = X(:,sort(list_real_idx_joint));
        Ynew = Y(:,sort(list_real_idx_joint));
        Znew = Z(:,sort(list_real_idx_joint));
        t= data_train(i).t;
        list_index_matrix= get_upper_index_matrix(length(list_real_idx_joint)*3);
        [ang_cov_matrix,cov_matrix] = covariance_features(Xnew, Ynew, Znew, t', nof_layer,overlap,timevar,list_index_matrix);
        % covariance skeleton
        concatcate_cov_to_vec = cell2mat(cellfun(@(x)(cell2mat(x)), reshape(cov_matrix, 1, []), 'UniformOutput', false));
        concatcate_cov_to_vec = concatcate_cov_to_vec/(norm(concatcate_cov_to_vec) +1e-5);
        % covariance velocity
        concatcate_cov_ang_to_vec = cell2mat(cellfun(@(x)(cell2mat(x)), reshape(ang_cov_matrix, 1, []), 'UniformOutput', false));
        concatcate_cov_ang_to_vec = concatcate_cov_ang_to_vec/(norm(concatcate_cov_ang_to_vec)+1e-5);
        feature_train{list_joint} =[feature_train{list_joint}; [concatcate_cov_to_vec,concatcate_cov_ang_to_vec]];
        label_centroid_train{list_joint}=[label_centroid_train{list_joint};label_train(i)];
    end    
fprintf('testing \n');
    feature_test=cell(nof_centroid,1);
    label_centroid_test=cell(nof_centroid,1);
    list_predict=[];
    for i =1:size(data_test,1)
        X = (data_test(i).x)';
        Y = (data_test(i).y)';
        Z = (data_test(i).z)';
        list_MIJ_each_action= getMostJoints(X,Y,Z,1,nof_MIJ_joints);
        list_joint = T(check_distance(list_MIJ_each_action,matrix_determine_joint));
        list_predict = [list_predict,list_joint];
        list_real_idx_joint= new_matrix_determine_joint{list_joint};
        Xnew = X(:,sort(list_real_idx_joint));
        Ynew = Y(:,sort(list_real_idx_joint));
        Znew = Z(:,sort(list_real_idx_joint));
        t =data_test(i).t;
        list_index_matrix = get_upper_index_matrix(length(list_real_idx_joint)*3);
        [ang_cov_matrix,cov_matrix] = covariance_features(Xnew, Ynew, Znew, t', nof_layer,overlap,timevar,list_index_matrix);
        % covariance skeleton
        concatcate_cov_to_vec = cell2mat(cellfun(@(x)(cell2mat(x)), reshape(cov_matrix, 1, []), 'UniformOutput', false));
        concatcate_cov_to_vec = concatcate_cov_to_vec/(norm(concatcate_cov_to_vec) +1e-5);
%         covariance velocity
%         concatcate_cov_ang_to_vec = cell2mat(cellfun(@(x)(cell2mat(x)), reshape(ang_cov_matrix, 1, []), 'UniformOutput', false));
        concatcate_cov_ang_to_vec = cell2mat(ang_cov_matrix{2});
        concatcate_cov_ang_to_vec = concatcate_cov_ang_to_vec/(norm(concatcate_cov_ang_to_vec)+1e-5);
        feature_test{list_joint} =[feature_test{list_joint}; [concatcate_cov_to_vec,concatcate_cov_ang_to_vec]];
        label_centroid_test{list_joint} =[label_centroid_test{list_joint};label_test(i)];
    end
list_predict_label =[];
list_label_test=[];
for c=1:nof_centroid
    model{c}= svmtrain(label_centroid_train{c}, feature_train{c}, '-c 100  -q -t 0 ');
    [predict_label, accuracy, prob_estimates] = svmpredict(label_centroid_test{c}, feature_test{c}, model{c}, '-b 0');
    list_predict_label =[list_predict_label;predict_label];
    list_label_test =[list_label_test;label_centroid_test{c}];
end
