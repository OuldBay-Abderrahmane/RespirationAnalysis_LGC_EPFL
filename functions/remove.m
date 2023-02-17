function [x] = remove(x, meanx, stdx)
    % [x] = remove(x, meanx, stdx)
    % Romve outlier using gaussian method keep all values below mean +-
    % 3*std
    % 
    % INPUT
    % - x: file 
    % - meanx: mean
    % - stdx : std
    %
    % OUTPUT :
    % x: x yithout outliers
    %
    % Developed by Abderrahmane Ould Bay - 15/02/2023

    STD_VAR = 3;
    
    for i = 1:length(x)
        if x(i) > meanx + STD_VAR*stdx
            x(i) = meanx + STD_VAR*stdx;
        elseif x(i) < meanx - STD_VAR*stdx
            x(i) = meanx - STD_VAR*stdx;
        end
    end
end