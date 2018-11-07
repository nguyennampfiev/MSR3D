addpath('./libsvm-3-4.22/matlab')
datadir=('./data');
addpath('./MostJoint')
action_set='ActionSet3.txt';
nof_joints=20;
nof_MIJ_joints =5;
nof_Action =20;
nof_layer =2;
overlap =false;
timevar =false;

actionName = {'Wave','Hammer','Smash','Catch','Forward Punch','Throw','Draw X','Draw Tick','Draw Circle','Clapping Hand','Two hand Wave','Side Boxing','Bend','Forward Kick','Side Kick','Jogging','Tennis Swing','Tennis Serve','Golf Swing','Pickup&throw'};
file = fopen(action_set,'r');
filename = cell(1,1);
h=1;
while ~feof(file)
    filename(h) = textscan(file,'%str\n');
    h =h+1;
end
fclose(file);
data_train =[]
label_train  = []
data_test =[]
label_test =[]
feature_cluster_train =[]
feature_cluster_test =cell(2,1);
tr=1;
te=1;
A =cell(nof_Action,1);
matrix_determine_joint =zeros(nof_Action,nof_MIJ_joints);
traningsubjects =[1,3,5,7,9];
for i = 1:size(filename,2)
    label_action = getLabelAction(char(filename{i}));
    data = load(fullfile(datadir,[char(filename{i}),'_skeleton3D.txt']));
    [n d] = size(data);
    noframes = n / nof_joints;
    x = reshape(data(:,1), nof_joints, noframes); % x
    y = reshape(data(:,2), nof_joints, noframes); % y
    z = reshape(data(:,3), nof_joints, noframes);
    t = 1:noframes; % z
    ske.x= x';
    ske.y=y';
    ske.z=z';
    ske.t=t';
    [~, cov_matrix] = calculateCovMats(ske.x, ske.y, ske.z,ske.t, nof_layer, overlap, timevar);
    concatcate_cov_to_vec = cell2mat(cellfun(@(x)(cell2mat(x)), reshape(cov_matrix, 1, []), 'UniformOutput', false));

    if( ~isempty(find(traningsubjects == getSubject(char(filename{i})),1)));
        data_train= [data_train; ske];
        label_test =[label_test;label_action];
        feature_cluster_train  = [feature_cluster_train ;concatcate_cov_to_vec];
%         size(feature_cluster_train{tr})
        tr=+1;
    else
       data_test= [data_test; ske];
       label_test= [label_test; label_action];
%         feature_cluster_test{te}=concatcate_cov_to_vec;
        te=+1;
    end
end
size(feature_cluster_train)
[idx,C] = kmeans(feature_cluster_train,2);
B =cell(3,1);
for i = 1:length(data_train)
  list_MIJ_each_action = getMostJoints(data_train(i).x,data_train(i).y,data_train(i).z,1,nof_MIJ_joints);
  B{idx(i)}= [B{idx(i)};list_MIJ_each_action]
end  
matrix_determine_joint =zeros(nof_Action,nof_MIJ_joints);
G = unique(label_train);
for k=1:length(unique(idx))
    matrix_determine_joint(k,:) = getIdxMostJoints(B{idx(k)},nof_MIJ_joints);
end