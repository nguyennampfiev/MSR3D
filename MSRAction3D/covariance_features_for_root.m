function cov_matrix = covariance_features_for_root(X, Y, Z, T, nof_layer, overlap,list_index_matrix)
    nFrames = size(X, 1);
    nJoints = size(X, 2);
    assert(size(Y, 1) == nFrames);
    assert(size(Z, 1) == nFrames);
    assert(size(T, 1) == nFrames);
    assert(size(Y, 2) == nJoints);
    assert(size(Z, 2) == nJoints);
    assert(size(T, 2) == 1);
    normX =normCor(X);
    normY =normCor(Y);
    normZ =normCor(Z);
    normT =normSeT(T);
    %  Compute  covariance matrix
    cov_matrix = cell(1, nof_layer);
    for l = 1:nof_layer
        nofMats = 2 ^ (l - 1);
        size_window = 1 / nofMats;
        step_window = size_window;
        if overlap
            step_window = step_window / 2;
            nofMats = nofMats * 2 - 1;
        end
        startFrameTimes = step_window * (0:(nofMats-1));
        cov_matrix{l}      = cell(1, nofMats);
        for i = 1:length(startFrameTimes)
            startTime = startFrameTimes(i);
            endTime = startFrameTimes(i) + size_window + 2 * eps;
            sliceInds = find(normT >= startTime & normT < endTime);
            sliceX = normX(sliceInds, :);
            sliceY = normY(sliceInds, :);
            sliceZ = normZ(sliceInds, :);
            slice_vars = [sliceX sliceY sliceZ];
            covariance_mat =cov(slice_vars);
            cov_matrix{l}{i} = covariance_mat(list_index_matrix);
        end

    end
end