function [pred_mat] = KN_Predictor(vip_route, T_max, post_matrix)
% 1, vip id; 2, vip route ID; 3, real experience of vip chosen route 
% for time t; 4, price for the choice; etc (other predictors); 
% 5, post_matrix service quality predictor
    nvip = size(vip_route, 1); 
    pred_mat = zeros(nvip*T_max, 5);
    for i = 1: 1: nvip
        pred_mat((i-1)*T_max+1: i*T_max, 1) = i;
        pred_mat((i-1)*T_max+1: i*T_max, 2) = ...
            datasample(1:vip_route(i), T_max);
        pred_mat((i-1)*T_max+1: i*T_max, 5) = ...
            post_matrix(i, pred_mat((i-1)*T_max+1: i*T_max, 2));
    end
    pred_mat(:, 3) = normrnd(0.3, 0.8, [nvip*T_max, 1]);
    pred_mat(:, 4) = exp(normrnd(0, 1, [nvip*T_max, 1]));
end

