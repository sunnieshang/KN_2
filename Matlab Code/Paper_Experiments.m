% Paper Experiments
clc; clearvars; rng('shuffle'); 
nvip = 200; T = 40;
CM = zeros(nvip*T, 4);
CM(:, 1) = kron((1: nvip)', ones(T, 1));
CM(:, 2) = repmat((1: T)', nvip, 1);
CM(:, 3) = 1 + binornd(1, 0.5, [nvip*T, 1]);
n_continuous = 0; 
Vip_route = repmat(2, nvip, 1);
CM(:, 4) = normrnd(0, 5, [T*nvip,1]);
point = 20; T_pre = 5;

route_min = 2; 
route_max = 2;
Prior_mat   = KN_Prior(n_continuous, nvip);
NPrior_mat = Prior_mat;
T_index = (1: T: T*(nvip-1)+1)';
MExp_mat = zeros(nvip*T, route_max + n_continuous + 1); % mean experience mat
MExp_mat_95 = zeros(nvip*T, 2*(route_max+ n_continuous + 1)); % 95% confidence interval
VExp_mat = zeros(nvip*T, 2); % variance experience mat (phi and nu_phi, sigma and xi in the paper)
VExp_mat_95 = zeros(nvip*T, 4); % 95% confidence interval
% [MExp_mat(T_index, :), VExp_mat(T_index, :)] = ...
%     KN_Exp(Prior_mat, n_continuous, route_max);
%% Pre-estimation to Update the Priors for each customer
for t = 1: T-1
    display(t);
    [MExp_mat(T_index+1, :), ...
     VExp_mat(T_index+1, :), ...
     NPrior_mat, ...
     MExp_mat_95(T_index+1, :), ...
     VExp_mat_95(T_index+1, :)] = KN_BUpdate(T_index, ...
                                             CM, ...
                                             Prior_mat, ...
                                             MExp_mat(T_index, :), ...
                                             VExp_mat(T_index, :), ...
                                             Vip_route, ...
                                             NPrior_mat,...
                                             MExp_mat_95(T_index, :), ...
                                             VExp_mat_95(T_index, :));
    T_index = T_index + 1;
end
MExp_mat = MExp_mat(1: nvip*T, :); 
VExp_mat = sqrt(1./VExp_mat);
X = [1, 0.638, -0.0261, -0.0767];
Coef = [-0.121, -0.142, -.362, 0.595, -0.103, -0.0379, -0.0117, -0.025]';
U(:, 1) = X*Coef(1:4) + MExp_mat(:, 1).*(MExp_mat(:, 1)>=0)*Coef(5) + ...
    MExp_mat(:, 1).*(MExp_mat(:, 1)<0)*Coef(6) + VExp_mat(:, 1)*Coef(7) + ...
    VExp_mat(:, 2)*Coef(8);
U(:, 2) = X*Coef(1:4) + MExp_mat(:, 2).*(MExp_mat(:, 2)>=0)*Coef(5) + ...
    MExp_mat(:, 2).*(MExp_mat(:, 2)<0)*Coef(6) + VExp_mat(:, 1)*Coef(7) + ...
    VExp_mat(:, 2)*Coef(8);

index = 1: T: 1+T*(nvip-1);
M = zeros(T, 2);
figure;
for i = 1:T
    M(i, 1) = mean(U(index, 1));
    M(i, 2) = mean(U(index, 2));   
    index = index + 1;
end
M = exp(M)./(1+exp(M));
plot(T_pre:T, M(T_pre:T,1), '-.o', T_pre:T, M(T_pre:T, 2),'--d',...
    'LineWidth',4,'MarkerSize',12);
legend('route 1',...
       'route 2');
legend boxoff;
set(gca,'fontsize',40)

%% Increase Variance
N1 = sum(CM(:,2)>=point & CM(:,3)==1);
CM2 = CM;
CM2(CM(:, 2)>=point & CM(:, 3)==1, 4) = normrnd(0, 20, [N1,1]);
T_index = (1: T: T*(nvip-1)+1)';
MExp_mat2 = zeros(nvip*T, route_max + n_continuous + 1); % mean experience mat
VExp_mat2 = zeros(nvip*T, 2); 
for t = 1: T-1
    display(t);
    [MExp_mat2(T_index+1, :), ...
     VExp_mat2(T_index+1, :), ...
     NPrior_mat, ...
     MExp_mat_95(T_index+1, :), ...
     VExp_mat_95(T_index+1, :)] = KN_BUpdate(T_index, ...
                                             CM2, ...
                                             Prior_mat, ...
                                             MExp_mat2(T_index, :), ...
                                             VExp_mat2(T_index, :), ...
                                             Vip_route, ...
                                             NPrior_mat,...
                                             MExp_mat_95(T_index, :), ...
                                             VExp_mat_95(T_index, :));
    T_index = T_index + 1;
end
VExp_mat2 = sqrt(1./sqrt(VExp_mat2));
U2(:, 1) = X*Coef(1:4) + MExp_mat2(:, 1).*(MExp_mat2(:, 1)>=0)*Coef(5) + ...
    MExp_mat2(:, 1).*(MExp_mat2(:, 1)<0)*Coef(6) + VExp_mat2(:, 1)*Coef(7) + ...
    VExp_mat2(:, 2)*Coef(8);
U2(:, 2) = X*Coef(1:4) + MExp_mat2(:, 2).*(MExp_mat2(:, 2)>=0)*Coef(5) + ...
    MExp_mat2(:, 2).*(MExp_mat2(:, 2)<0)*Coef(6) + VExp_mat2(:, 1)*Coef(7) + ...
    VExp_mat2(:, 2)*Coef(8);

index = 1: T: 1+T*(nvip-1);
M2 = zeros(T, 2);
figure;
for i = 1:T
    M2(i, 1) = mean(U2(index, 1));
    M2(i, 2) = mean(U2(index, 2));   
    index = index + 1;
end
M2 = exp(M2)./(1+exp(M2));
plot(T_pre:T, M2(T_pre:T,1), '-.o', T_pre:T, M2(T_pre:T, 2),'--d',...
    'LineWidth',4,'MarkerSize',12);
legend('route 1',...
       'route 2');
legend boxoff;
set(gca,'fontsize',40)
hold on;
y=get(gca,'ylim');
plot([point,point], y, '--','LineWidth',3);

%% Reduce Mean
CM3 = CM;
CM3(CM(:, 2)>=point & CM(:, 3)==1, 4) = normrnd(5, 5, [N1,1]);
T_index = (1: T: T*(nvip-1)+1)';
MExp_mat3 = zeros(nvip*T, route_max + n_continuous + 1); % mean experience mat
VExp_mat3 = zeros(nvip*T, 2); 
for t = 1: T-1
    display(t);
    [MExp_mat3(T_index+1, :), ...
     VExp_mat3(T_index+1, :), ...
     NPrior_mat, ...
     MExp_mat_95(T_index+1, :), ...
     VExp_mat_95(T_index+1, :)] = KN_BUpdate(T_index, ...
                                             CM3, ...
                                             Prior_mat, ...
                                             MExp_mat3(T_index, :), ...
                                             VExp_mat3(T_index, :), ...
                                             Vip_route, ...
                                             NPrior_mat,...
                                             MExp_mat_95(T_index, :), ...
                                             VExp_mat_95(T_index, :));
    T_index = T_index + 1;
end
VExp_mat3 = sqrt(1./sqrt(VExp_mat3));
U3(:, 1) = X*Coef(1:4) + MExp_mat3(:, 1).*(MExp_mat3(:, 1)>=0)*Coef(5) + ...
    MExp_mat3(:, 1).*(MExp_mat3(:, 1)<0)*Coef(6) + VExp_mat3(:, 1)*Coef(7) + ...
    VExp_mat3(:, 2)*Coef(8);
U3(:, 2) = X*Coef(1:4) + MExp_mat3(:, 2).*(MExp_mat3(:, 2)>=0)*Coef(5) + ...
    MExp_mat3(:, 2).*(MExp_mat3(:, 2)<0)*Coef(6) + VExp_mat3(:, 1)*Coef(7) + ...
    VExp_mat3(:, 2)*Coef(8);

index = 1: T: 1+T*(nvip-1);
M3 = zeros(T, 2);
figure;
for i = 1:T
    M3(i, 1) = mean(U3(index, 1));
    M3(i, 2) = mean(U3(index, 2));   
    index = index + 1;
end
M3 = exp(M3)./(1+exp(M3));
plot(T_pre:T, M3(T_pre:T,1), '-.o', T_pre:T, M3(T_pre:T, 2),'--d',...
    'LineWidth',4,'MarkerSize',12);
legend('route 1',...
       'route 2');
legend boxoff;
set(gca,'fontsize',40)
hold on;
y=get(gca,'ylim');
plot([point,point], y, '--','LineWidth',3);

%% Add Disruptions
index = point:T:point+T*(nvip-1);
CM4 = CM;
CM4(index, 3) = 1; CM4(index+1, 3) = 1;
CM4(index, 4) = 48; CM4(index+1, 4) = -48;
T_index = (1: T: T*(nvip-1)+1)';
MExp_mat4 = zeros(nvip*T, route_max + n_continuous + 1); % mean experience mat
VExp_mat4 = zeros(nvip*T, 2); 
for t = 1: T-1
    display(t);
    [MExp_mat4(T_index+1, :), ...
     VExp_mat4(T_index+1, :), ...
     NPrior_mat, ...
     MExp_mat_95(T_index+1, :), ...
     VExp_mat_95(T_index+1, :)] = KN_BUpdate(T_index, ...
                                             CM4, ...
                                             Prior_mat, ...
                                             MExp_mat4(T_index, :), ...
                                             VExp_mat4(T_index, :), ...
                                             Vip_route, ...
                                             NPrior_mat,...
                                             MExp_mat_95(T_index, :), ...
                                             VExp_mat_95(T_index, :));
    T_index = T_index + 1;
end
VExp_mat4 = sqrt(1./sqrt(VExp_mat4));
U4(:, 1) = X*Coef(1:4) + MExp_mat4(:, 1).*(MExp_mat4(:, 1)>=0)*Coef(5) + ...
    MExp_mat4(:, 1).*(MExp_mat4(:, 1)<0)*Coef(6) + VExp_mat4(:, 1)*Coef(7) + ...
    VExp_mat4(:, 2)*Coef(8);
U4(:, 2) = X*Coef(1:4) + MExp_mat4(:, 2).*(MExp_mat4(:, 2)>=0)*Coef(5) + ...
    MExp_mat4(:, 2).*(MExp_mat4(:, 2)<0)*Coef(6) + VExp_mat4(:, 1)*Coef(7) + ...
    VExp_mat4(:, 2)*Coef(8);

index = 1: T: 1+T*(nvip-1);
M4 = zeros(T, 2);
figure;
for i = 1:T
    M4(i, 1) = mean(U4(index, 1));
    M4(i, 2) = mean(U4(index, 2));   
    index = index + 1;
end
M4 = exp(M4)./(1+exp(M4));
plot(T_pre:T, M4(T_pre:T,1), '-.o', T_pre:T, M4(T_pre:T, 2),'--d',...
    'LineWidth',4,'MarkerSize',12);
legend('route 1',...
       'route 2');
legend boxoff;
set(gca,'fontsize',40)
hold on;
y=get(gca,'ylim');
plot([point,point], y, '--','LineWidth',3);


%% Do nothing for the disruption
index = point:T:point+T*(nvip-1);
CM5 = CM;
CM5(index, 3) = 1; 
CM5(index, 4) = 48; 
T_index = (1: T: T*(nvip-1)+1)';
MExp_mat5 = zeros(nvip*T, route_max + n_continuous + 1); % mean experience mat
VExp_mat5 = zeros(nvip*T, 2); 
for t = 1: T-1
    display(t);
    [MExp_mat5(T_index+1, :), ...
     VExp_mat5(T_index+1, :), ...
     NPrior_mat, ...
     MExp_mat_95(T_index+1, :), ...
     VExp_mat_95(T_index+1, :)] = KN_BUpdate(T_index, ...
                                             CM5, ...
                                             Prior_mat, ...
                                             MExp_mat5(T_index, :), ...
                                             VExp_mat5(T_index, :), ...
                                             Vip_route, ...
                                             NPrior_mat,...
                                             MExp_mat_95(T_index, :), ...
                                             VExp_mat_95(T_index, :));
    T_index = T_index + 1;
end
VExp_mat5 = sqrt(1./sqrt(VExp_mat5));
U5(:, 1) = X*Coef(1:4) + MExp_mat5(:, 1).*(MExp_mat5(:, 1)>=0)*Coef(5) + ...
    MExp_mat5(:, 1).*(MExp_mat5(:, 1)<0)*Coef(6) + VExp_mat5(:, 1)*Coef(7) + ...
    VExp_mat5(:, 2)*Coef(8);
U5(:, 2) = X*Coef(1:4) + MExp_mat5(:, 2).*(MExp_mat5(:, 2)>=0)*Coef(5) + ...
    MExp_mat5(:, 2).*(MExp_mat5(:, 2)<0)*Coef(6) + VExp_mat5(:, 1)*Coef(7) + ...
    VExp_mat5(:, 2)*Coef(8);

index = 1: T: 1+T*(nvip-1);
M5 = zeros(T, 2);
figure;
for i = 1:T
    M5(i, 1) = mean(U5(index, 1));
    M5(i, 2) = mean(U5(index, 2));   
    index = index + 1;
end
M5 = exp(M5)./(1+exp(M5));
plot(T_pre:T, M5(T_pre:T,1), '-.o', T_pre:T, M5(T_pre:T, 2),'--d',...
    'LineWidth',4,'MarkerSize',12);
legend('route 1',...
       'route 2');
legend boxoff;
set(gca,'fontsize',40)
hold on;
y=get(gca,'ylim');
plot([point,point], y, '--','LineWidth',3);

save Paper_Experiments.mat