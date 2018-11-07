function [ang_covMats, covMats] = calculateCovMats(X, Y, Z, T, nLevels, overlap, timeVar)
nFrames = size(X, 1);
nJoints = size(X, 2);
assert(size(Y, 1) == nFrames);
assert(size(Z, 1) == nFrames);
assert(size(T, 1) == nFrames);
assert(size(Y, 2) == nJoints);
assert(size(Z, 2) == nJoints);
assert(size(T, 2) == 1);
if nargin < 7 || isempty(timeVar)
    timeVar = true;
end
normX =normCor(X);
normY =normCor(Y);
normZ =normCor(Z);
normT =normSeT(T);
normX_ang = normCor(compute_angular_joints(X));
normY_ang = normCor(compute_angular_joints(Y));
normZ_ang = normCor(compute_angular_joints(Z));

if timeVar
    sizeMatrix = nJoints * 3 + 1;
else
    sizeMatrix = nJoints * 3;
end
listIdxMatrix = getValueMatrix(sizeMatrix);

ang_covMats = cell(nLevels, 1);
covMats = cell(nLevels, 1);
for l = 1:nLevels
    nofMats = 2 ^ (l - 1);
    sizeWindow = 1 / nofMats;
    stepWindow = sizeWindow;
    if overlap
        stepWindow = stepWindow / 2;
        nofMats = nofMats * 2 - 1;
    end
    startFrameTimes = stepWindow * (0:(nofMats-1));
    ang_covMats{l} = cell(1, nofMats);
    covMats{l} = cell(1, nofMats);
    for i = 1:length(startFrameTimes)
        startTime = startFrameTimes(i);
        endTime = startFrameTimes(i) + sizeWindow + 2 * eps;
        sliceInds = find(normT >= startTime & normT < endTime);
        sliceX = normX(sliceInds, :);
        sliceY = normY(sliceInds, :);
        sliceZ = normZ(sliceInds, :);
        sliceT = normT(sliceInds, :);
        sliceX_ang = normX_ang(sliceInds, :);
        sliceY_ang = normY_ang(sliceInds, :);
        sliceZ_ang = normZ_ang(sliceInds, :);
        if ~timeVar
            sliceVars = [sliceX sliceY sliceZ];
            slice_vars_ang =[sliceX_ang sliceY_ang sliceZ_ang];
        else 
            sliceVars = [sliceX sliceY sliceZ sliceT];
            slice_vars_ang =[sliceX_ang sliceY_ang sliceZ_ang];
        end
        covarianceMat = cov(sliceVars);
        covariance_mat_ang= cov(slice_vars_ang);
        ang_covMats{l}{i} = covariance_mat_ang(listIdxMatrix);
        covMats{l}{i} = covarianceMat(listIdxMatrix);
    end
end
