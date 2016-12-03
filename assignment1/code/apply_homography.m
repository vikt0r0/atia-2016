function [ P_e ] = apply_homography( h, P )
%APPLY_HOMOGRAPHY Apply homography  and normalize to euclidean scale.
%   Expects input of the format [ x0 x1 x2 ... yn; y0 y1 y2 ... yn ]

        % Homogenous coordinates
        P_h = h * [ P; ones(1, size(P,2)) ];

        % Euclidean coordinates
        P_e = P_h(1:2,:) ./ repmat(P_h(3,:), [2,1]);
end

