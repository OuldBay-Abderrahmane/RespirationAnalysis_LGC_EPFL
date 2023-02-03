
function [x] = remove(x, meanx, stdx)
    STD_VAR = 3;
    
    for i = 1:length(x)
        if x(i) > meanx + STD_VAR*stdx
            x(i) = meanx + STD_VAR*stdx;
        elseif x(i) < meanx - STD_VAR*stdx
            x(i) = meanx - STD_VAR*stdx;
        end
    end
end