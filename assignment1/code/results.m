function [ H ] = results( r, s, od )
%RESULTS Get the assignment 1 results
%   Returns a struct with original, rectified and bitmap data as
%   well as error measures. r is the dataset to use, r \in [1, 2]
%   s is the image to use, s \in [1...5] and od \in [true, false]
%   enables outlier detection.

    %% Configuration

    % Dataset, i \in [1, 2]
    i = r;

    % Image number, j \in [1...5]
    j = s;

    % Paths and files
    data_path = 'data/';
    data_file_name = strcat(data_path, 'points', int2str(i), '.mat');

    % Outlier detection
    ransac = od;

    % Homography data
    H = struct();
    H.i = i;
    H.j = j;

    % Load the file name
    load(data_file_name);

    % Estimate
    Px_est = Px;
    Py_est = Py;

    %% Outlier detection

    sample_size = 5;
    outlier_treshold = 1 * 10^5;
    inliers = [];
    mse = Inf;

    if ransac
        % Assume ~30% chance of an outlier
        for t=1:2000
            % Reference points
            P = [ Px(j,:); Py(j,:); Px(1,:); Py(1,:) ]';

            % Randomly sample a subset of data. We need 5 for 9 parameters
            rand = randperm(size(P, 1));
            r1 = rand(1:sample_size);
            r2 = rand(sample_size+1:end);

            % Compute the model
            S = P(r1, :);
            h = homography(S);

            % Apply the model
            S_ref = P(r2, 3:4)';
            S_rect = apply_homography(h, P(r2, 1:2)');

            % Compute error
            mse_cand = sum((S_rect - S_ref).^2);

            % Compute inliers
            inliers_cand = rand(mse < outlier_treshold);

            % Update inlier set and MSE
            if length(inliers_cand) >= length(inliers)
                if length(inliers_cand) == length(inliers)
                    % Inlier set and candidate set has same cardinality
                    if mse_cand < mse
                        inliers = inliers_cand;
                        mse = mse_cand;
                    end
                else
                    % Inlier candidate set is strictly larger
                    inliers = inliers_cand;
                end
            end
        end

        % Only use inliers
        Px_est = Px(:, inliers);
        Py_est = Py(:, inliers);
    end

    %% Homography estimation

    % Reference points
    P_ref = [ Px(1,:); Py(1,:) ];

    % Original points
    P = [ Px(j,:); Py(j,:) ];

    % Compute the homography
    [ h, ~ ] = homography([ Px_est(j,:); Py_est(j,:); Px_est(1,:); Py_est(1,:) ]');

    % And its inverse
    h_inv = homography([ Px_est(1,:); Py_est(1,:); Px_est(j,:); Py_est(j,:) ]');

    % Apply the homography
    P_e = apply_homography(h, P);

    % Save homographies and points
    H.hom = h;
    H.hom_inv = h_inv;

    H.pts_ref = P_ref;
    H.pts_orig = P;
    H.pts_rect = P_e;

    % Save images
    H.img_ref = imread(strcat('images/im', int2str(i), int2str(1), '.jpg'));
    H.img_orig = imread(strcat('images/im', int2str(i), int2str(j), '.jpg'));
    H.img_ref_bm = create_bitmap(H.img_ref, H.pts_ref);

    %% Image rectification

    % Load the image to rectify
    I = H.img_orig;

    % Rectified image
    I_rect = uint8(ones(size(H.img_ref))*255);

    % Apply the reverse homography for all pixel coordinates.
    P = combvec(1:size(I_rect,1),1:size(I_rect,2));
    P_inv = round((apply_homography(H.hom_inv, P)));

    % Copy nearest pixel values into rectified image
    for k=1:size(P,2)
        p = P(:,k);
        p_i = P_inv(:,k);
        if (0 < p_i(1) && p_i(1) <= size(I,1) && 0 < p_i(2) && p_i(2) <= size(I,2))
            I_rect(p(1),p(2),:) = I(p_i(1), p_i(2), :);
        end
    end

    % Save images
    H.img_rect = I_rect;
    H.img_rect_bm = create_bitmap(I_rect, H.pts_rect);

    %% Error measures

    % Mean squared error
    H.mse = mean(sum((P_e - [ Px(1,:); Py(1,:) ]).^2), 2);

    % Jaccard index of tresholded image
    H.jacc = jaccard(H.img_rect_bm, H.img_ref_bm);

end

