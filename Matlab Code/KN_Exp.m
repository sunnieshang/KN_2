function Exp_mat = KN_Exp(prior_mat, n_conti, route_max)
    nvip = size(prior_mat, 1);
    Exp_mat = zeros(nvip, route_max+n_conti+1);
    Exp_mat(:, 1:route_max) = ...
        repmat(prior_mat(:, 1), 1, route_max);
    Exp_mat(:, route_max+1:route_max+n_conti) = ...
        repmat(prior_mat(:, 6), 1, n_conti);
    Exp_mat(:, end) = prior_mat(:, 3).*prior_mat(:, 4);
end