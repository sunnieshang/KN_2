function Exp_mat = KN_Exp(prior_mat, n_conti)
    nvip = size(prior_mat, 1);
    route_max = size(prior_mat, 2) - 7;
    Exp_mat = zeros(nvip, route_max+n_conti+1);
    Exp_mat(:, 1:route_max) = ...
        repmat( prior_mat(:, route_max+1), 1, route_max);
    Exp_mat(:, route_max+1:route_max+n_conti) = 0;
    Exp_mat(:, end) = ...
        prior_mat(:, route_max+3).*prior_mat(:, route_max+4);
end