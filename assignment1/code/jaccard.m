function [ i ] = jaccard( A,B )
%JACCARD Compute the Jaccard index of two evenly sized bitmaps
%   Computes the Jaccard index, i.e. |A \cap B|/|A \cup B|...
    i = sum(sum(A & B)) / sum(sum(A | B));
end