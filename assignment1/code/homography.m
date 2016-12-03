function [ h, sv ] = homography( P )
%CONSTRAINT Creates 2d homography constraints for corresponding points
%   Assumes P has the shape
%
%       [x1_1 y1_1 x2_1 y2_1;
%        x1_2 y1_2 x2_2 y2_2;
%        ...
%        x1_n y1_n x2_n y2_n]
%
%   where (x1_i, y1_i) and (x2_i y2_i) are
%   corresponding points for 1 <= i <= n.
%
    % Helper to generate a pair of constraints.
    c = @( x1, y1, x2, y2 ) [-x1 -y1 -1 0 0 0 x2*x1 x2*y1 x2; 0 0 0 -x1 -y1 -1 y2*x1 y2*y1 y2];
    m = @( r ) c(r(1), r(2), r(3), r(4));
    
    % Generate all the constraints
    cons = cellfun(m, num2cell(P,2), 'UniformOutput', 0);
    cons = cell2mat(cons);
    
    % Perform SVD to find the best h.
    [~, S, V] = svd(cons);
    
    % Return the best h and its singular value.
    h = transpose(reshape(V(:,end),[3,3])); sv = max(S(:,end));
end