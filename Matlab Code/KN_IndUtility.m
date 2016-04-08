function IndU = KN_IndUtility(T_index,...
                              beta,...
                              X,...
                              vip_route)
%% TODO: need to change the coefficient matrix into 3D matrix 
%% so that we have the matrix all routes in every decision when 
%% we don't actually ship since every route is possible
    IndU = zeros(size(X, 1), max(vip_route));
    T = size(X, 1)/length(vip_route);
    beta = reshape(beta, size(beta,1), 1, size(beta,2));
    for i=1:length(vip_route)
        IndU((i-1)*T+1:i*T, 1:vip_route(i)) = sum(X(T_index((i-1)*T+1:i*T), 1:vip_route(i), :).*...
            repmat(beta(i,1, :), T, vip_route(i), 1), 3);
    end
end