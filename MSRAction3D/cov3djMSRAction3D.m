clear all;
close all;
clc;
addpath('./libsvm-3-4.22/matlab')

datadir =('./data');
actionset = 'ActionSet2.txt'; % select the action set

% Get valid filenames
file = fopen(actionset, 'r');

filenames = cell(1,1);

i = 1;
while ~feof(file)
    filenames(i) = textscan(file, '%str\n');
    i = i + 1;
end
fclose(file);

data = cell(2,1);
labels = zeros(2,1);
testdata = cell(2,1);
testlabels = zeros(2,1);
di = 1; % counter for data
ti = 1;
len = size(filenames, 2);
trainingsubjects = [1  3  5 7 9]; % the standard setup
for i = 1:len
    if (~isempty(find(trainingsubjects == getSubject(char(filenames{i})), 1)))% first 5 subjects as training
        data{di} = load (fullfile(datadir, [char(filenames{i}), '_skeleton3D.txt']));
        labels(di) = getLabelAction(char(filenames{i}));
        di = di + 1;
    else
        testdata{ti} = load(fullfile(datadir, [char(filenames{i}), '_skeleton3D.txt']));
        testlabels(ti) = getLabelAction(char(filenames{i}));
        ti = ti + 1;
    end
end


nofparts = 20;
remove_test=[];
len = size(data, 1);
remov=zeros(1,len);
fprintf('training')
for i = 1:len;
    % i
   arr = data{i};
   [n d] = size(arr);
   noframes = n / nofparts;

   x = reshape(arr(:,1), nofparts, noframes); % x
   y = reshape(arr(:,2), nofparts, noframes); % y
   z = reshape(arr(:,3), nofparts, noframes); % z
   t = 1:noframes; %t
   [~,covmat] = calculateCovMats(x', y', z', t', 3, true,false);
%    rowdata1(i,:)= reshape(   cat(1,covmat{1}{:}),	1,[]);
   rowdata3_o(i,:) =reshape(   [cat(1,covmat{3}{:});cat(1,covmat{2}{:});cat(1,covmat{1}{:})],1,[]);
    % rowdata2_o(i,:) =  reshape(   [cat(1,covmat{2}{:});cat(1,covmat{1}{:})],	1,[]);
    % covmat = compute_cov_mats(x', y', z', t', 3, false);
    % rowdata3(i,:) =reshape(   [cat(1,covmat{3}{:});cat(1,covmat{2}{:});cat(1,covmat{1}{:})],	1,[]);
    % rowdata2(i,:) =reshape(   [cat(1,covmat{2}{:});cat(1,covmat{1}{:})],1,[]);

end

nofparts = 20;
remove_test=[];
len = size(testdata, 1);
remov=zeros(1,len);
%rowdata = zeros(len, dims);
% Process the dataset
fprintf('testing');
for i = 1:len;
    % i
   arr = testdata{i};
   [n d] = size(arr);
   noframes = n / nofparts;
   x = reshape(arr(:,1), nofparts, noframes); % x
   y = reshape(arr(:,2), nofparts, noframes); % y
   z = reshape(arr(:,3), nofparts, noframes); % z
   t = 1:noframes; %t

  [~,covmat] = calculateCovMats(x', y', z', t', 3, true,false);
%    rowdata1_te(i,:)= reshape(   cat(1,covmat{1}{:}),	1,[]);
     rowdata3_o_te(i,:) =reshape(   [cat(1,covmat{3}{:});cat(1,covmat{2}{:});cat(1,covmat{1}{:})],	1,[]);
    % rowdata2_o_te(i,:) =  reshape(   [cat(1,covmat{2}{:});cat(1,covmat{1}{:})],	1,[]);
%    covmat = compute_cov_mats(x', y', z', t', 3, false);
    % rowdata3_te(i,:) =reshape(   [cat(1,covmat{3}{:});cat(1,covmat{2}{:});cat(1,covmat{1}{:})],	1,[]);
    % rowdata2_te(i,:) =reshape(   [cat(1,covmat{2}{:});cat(1,covmat{1}{:})],1,[]);

end

% %with normalization
% model=svmtrain(labels, normr(rowdata3_o), '-c 10  -q  -t 0 -b 1');
% [predict_label, accuracy, prob_estimates] = svmpredict(testlabels, normr(rowdata3_o_te), model, '-b 1');
% 

model=svmtrain(labels, rowdata3_o, '-c 10  -q -t 0 -b 1');
[predict_label, accuracy, prob_estimates] = svmpredict(testlabels, rowdata3_o_te, model, '-b 1');
fprintf('%s data file created successfully.\n', actionset);
%clear all;
%close all;