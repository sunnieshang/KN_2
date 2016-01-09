function [MExp_mat, VExp_mat] = KN_Exp(prior_mat, n_conti, route_max)
    nvip = size(prior_mat, 1);
    MExp_mat = zeros(nvip, route_max+n_conti);
    MExp_mat(:, 1:route_max) = ...
        repmat(prior_mat(:, 1), 1, route_max);
    MExp_mat(:, route_max+1:end) = ...
        repmat(prior_mat(:, 6), 1, n_conti);
    VExp_mat = prior_mat(:, 3).*prior_mat(:, 4);
end