function IndU = KN_IndUtility(T_index,... 
                              gamma,...
                              beta,...
                              Exp_mat, ID_mat)
%% TODO: need to change the coefficient matrix into 3D matrix 
%% so that we have the matrix all routes in every decision when 
%% we don't actually ship since every route is possible
    IndU = zeros(size(Exp_mat, 1), size(Exp_mat, 2) - 1);
    for i = 1: size(Exp_mat, 2) - 1
        IndU(:, i) = gamma + ID_mat(T_index, 4).* beta(:, 1) ...
            + Exp_mat(:, i).* beta(:, 2); 
    end
end

