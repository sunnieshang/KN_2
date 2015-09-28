function [IndU] = KN_IndUtility(T_index, gamma, beta,data_predictor)
    IndU = gamma + sum(data_predictor(T_index,4:5).*beta,2);
end

