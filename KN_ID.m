function [ID_mat] = KN_ID(vip_route, T)
% 1, vip id; 2, vip route ID; 3, real experience of vip chosen route 
% for time t; 4, price for the choice; etc (other predictors); 
% 5, post_matrix service quality predictor
    nvip         = size(vip_route, 1); 
    ID_mat       = zeros(nvip*T, 7);
    ID_mat(:, 1) = kron((1: nvip)', ones(T, 1));
    ID_mat(:, 2) = repmat((1: T)', nvip, 1);
    for i=1:nvip
        ID_mat((i-1)*T+1: i*T, 3) = datasample(1:vip_route(i), T);
    end
    ID_mat(:, 4) = exp(normrnd(0, 1, [nvip*T, 1])); % price
    ID_mat(:, 5) = normrnd(0.3, 0.8, [nvip*T, 1]);  % real experience
end

