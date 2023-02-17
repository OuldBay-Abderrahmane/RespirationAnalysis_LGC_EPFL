function [val] = getBRInsideCell(array, i)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    if ~isempty(array)
        val = array{i}(2);
        val = val{1}(1);
        val = val{1};
    else 
        val = NaN;
    end
end