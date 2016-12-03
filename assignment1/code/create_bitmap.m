function [ bm ] = create_bitmap( I, coords )
%CREATE_BITMAP Create a bitmap
%   Create a bitmap using Otzu's method followed
%   by masking with an inflated convex hull.
    
    % Get indices of points on the convex hull
    i_cvx = convhull(coords(1,:), coords(2,:));
    
    % Get points on the convex hull
    p_cvx = coords(:, i_cvx);
    
    % Inflate the hull, i.e. translate to origin by mean, scale
    % by a factor and translate back.
    mean_v = repmat(mean(p_cvx,2),[1 size(p_cvx,2)]);
    p_cvx = p_cvx - mean_v;
    p_cvx = p_cvx * 1.1;
    p_cvx = p_cvx + mean_v;
    
    % Create bitmap
    level = graythresh(I);
    I_bw = imcomplement(im2bw(I, level));
    
    % Map only the leaf region
    leaf_region_bm = logical(zeros(size(I_bw)));
    
    % Get all x and y coordinates.
    min_x = max([ 0 round(min(p_cvx(1,:)))]);
    max_x = min([ size(I_bw,1) round(max(p_cvx(1,:)))]);
    min_y = max([ 0 round(min(p_cvx(2,:)))]);
    max_y = min([ size(I_bw,2) round(max(p_cvx(2,:)))]);
    
    % All points in rectangle containing the convex hull
    P = combvec(min_x:max_x, min_y:max_y);
    
    % Bit vector indicating which coordinates are in the convex hull
    in = inpolygon(P(2,:),P(1,:),p_cvx(2,:),p_cvx(1,:)');
    
    % Coordinates in the convex hull
    P_in = P(:,in);
    
    for k=1:size(P_in,2)
        p = P_in(:,k);
        leaf_region_bm(p(1),p(2)) = 1;
    end
    
    bm = I_bw & leaf_region_bm;
end
