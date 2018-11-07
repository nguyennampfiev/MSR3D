addpath('./libsvm-3-4.22/matlab')
datadir =('./data');
addpath('./MostJoint');
addpath('./tSNE_matlab');

actionset='ActionSet2.txt';
nofparts=20;
noMostJoints =20;
noAction =20;

file = fopen(actionset,'r');
filename = cell(1,1);
h=1;
while ~feof(file)
    filename(h) = textscan(file,'%str\n');
    h =h+1;
end
fclose(file);
data =cell(2,1);
labels = zeros(2,1);
testdata = cell(2,1);
testlabels =zeros(2,1);
listLabel =[];
di = 1; % counter for data
ti = 1;
len =size(filename,2);
A =cell(noAction,1);
matrixIndexJoint =zeros(noAction,noMostJoints);
traningsubjects =[1,3,5,7,9];
for i = 1:len
    if( ~isempty(find(traningsubjects == getSubject(char(filename{i})),1)));
        data{di} = load(fullfile(datadir,[char(filename{i}),'_skeleton3D.txt']));
        labels(di) = getLabelAction(char(filename{i}));
        [n d] = size(data{di});
        noframes = n / nofparts;
        x = reshape(data{di}(:,1), nofparts, noframes); % x
        y = reshape(data{di}(:,2), nofparts, noframes); % y
        z = reshape(data{di}(:,3), nofparts, noframes); % z
        t = 1:noframes;
        listIdx = getMostJoints(x',y',z',1,noMostJoints);
        A{labels(di)} = [A{labels(di)};listIdx];  
        di=di+1;
    else
        testdata{ti} =load(fullfile(datadir,[char(filename{i}),'_skeleton3D.txt']));
        testlabels(ti) = getLabelAction(char(filename{i}));
        ti = ti+1;   
    end
end
G = unique(labels);
for k=1:length(G)
    G(k)
    matrixIndexJoint(G(k),:) = getIdxMostJoints(A{G(k)},noMostJoints);
end
matrixIndexJoint

% train with multi model  
len =size(testdata,1);
fprintf('training \n');
    rowdata3_train=[];
    for i =1:len
        arr =testdata{i};
        [n d]  = size(arr);
        noframes = n / nofparts;
        x = reshape(arr(:,1),nofparts,noframes);
        y = reshape(arr(:,2),nofparts,noframes);
        z = reshape(arr(:,3),nofparts,noframes);
        t =1:noframes;
        listJoints = matrixIndexJoint(testlabels(i),:);
        Xnew = x(sort(listJoints),:);
        Ynew = y(sort(listJoints),:);
        Znew = z(sort(listJoints),:);
        covmat = compute_cov_mats(Xnew', Ynew', Znew', t', 3,true);
        normVec = cell2mat(cellfun(@(x)(cell2mat(x)), reshape(covmat, 1, []), 'UniformOutput', false));
        rowdata3_train =[rowdata3_train; normVec];
    end
    no_dims = 2; initial_dims = 50; perplexity = 30;
    % Run t-SNE
   % % opts = statset('MaxIter',10000);
    mappedX = tsne(rowdata3_train, [], no_dims, initial_dims, perplexity);
   % % Plot results
    gscatter(mappedX(:,1), mappedX(:,2), testlabels);

