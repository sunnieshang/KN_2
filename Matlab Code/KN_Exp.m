function [MExp_mat, VExp_mat] = KN_Exp(prior_mat, n_conti, route_max)
    nvip = size(prior_mat, 1);
    MExp_mat = zeros(nvip, route_max+1+n_conti);
    MExp_mat(:, 1:route_max+1) = ...
        repmat(prior_mat(:, 1), 1, route_max+1);
    if (n_conti>0)
        MExp_mat(:, route_max+2:end) = ...
            repmat(prior_mat(:, 6), 1, n_conti);
    end
    VExp_mat(:, 1) = prior_mat(:, 3).*prior_mat(:, 4);
    VExp_mat(:, 2) = prior_mat(:, 5).*prior_mat(:, 6);
end