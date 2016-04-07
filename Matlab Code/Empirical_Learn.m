clc; clearvars; rng('shuffle'); 
%% Read In Date
Complete_mat = csvread('Exp_mat.csv', 1, 0);
% 1, child_id; 2, complete_period; 3, route_1; 4, delay_1; 
% 5, route_2; 6, delay_2; 7, r_3; 8, d_3, 9, r_4, 10, d_4, 11, r_5, 12, d_5, 
% 13, r_6; 14, d_6,15, r_7; 16, d_7; 17, complete or not
Vip_route = csvread('Child_Route_Num.csv', 1, 0)'; % nvip * 1
P_mat = csvread('P_mat.csv'); 
logP_mat = csvread('logP_mat.csv');
Start_mat = csvread('ID_mat.csv'); 
% Start_mat: 1, child_id; 2, start period; 3, route_id; 4, ship or not
Pred_mat = csvread('Predictor.csv');
Start_mat(:, 5) = Start_mat(:, 4);
Start_mat(Start_mat(:, 3)==0, 3) = 1;
Start_mat(:, 4) = logP_mat(sub2ind(size(P_mat), (1:1:size(Start_mat,1))', Start_mat(:, 3))); 
% logP_mat = (logP_mat - mean(mean(logP_mat)))/1.5;
T = 103; % 3.5 days period 

%% Normalization 
Pred_mat = Pred_mat/4000;
Complete_mat(:, end) = Complete_mat(:, end)/4000;
P_mat = P_mat/1000;

%% Sample Customer
% c_min = 0; c_max = 50;
% Vip_route = Vip_route(c_min + 1: c_max);
% Complete_mat = Complete_mat(Complete_mat(:, 1)>c_min & Complete_mat(:, 1)<=c_max,:);
% P_mat = P_mat(c_min*T + 1: c_max*T, :);
% logP_mat = logP_mat(c_min*T + 1: c_max*T, :);
% Pred_mat = Pred_mat(c_min*T + 1: c_max*T, :);
% Start_mat = Start_mat(c_min*T + 1: c_max*T, :);

%% Bayesian Learning of the shippers' experiences (2 hours on Latte for 122 periods)
T_pre = 24;
nvip = size(P_mat, 1)/T;
route_min = 2; 
route_max = 6;
n_continuous = 0;
Prior_mat   = KN_Prior(n_continuous, nvip);
NPrior_mat = Prior_mat;
T_index = (1: T: T*(nvip-1)+1)';
MExp_mat = zeros(nvip*T, route_max + n_continuous + 1); % mean experience mat
MExp_mat_95 = zeros(nvip*T, 2*(route_max+ n_continuous + 1)); % 95% confidence interval
VExp_mat = zeros(nvip*T, 2); % variance experience mat (phi and nu_phi, sigma and xi in the paper)
VExp_mat_95 = zeros(nvip*T, 4); % 95% confidence interval
[MExp_mat(T_index, :), VExp_mat(T_index, :)] = ...
    KN_Exp(Prior_mat, n_continuous, route_max);
%% Pre-estimation to Update the Priors for each customer
for t = 1: T_pre
    display(t);
    [MExp_mat(T_index+1, :), ...
     VExp_mat(T_index+1, :), ...
     NPrior_mat, ...
     MExp_mat_95(T_index+1, :), ...
     VExp_mat_95(T_index+1, :)] = KN_BUpdate(T_index, ...
                                             Complete_mat, ...
                                             Prior_mat, ...
                                             MExp_mat(T_index, :), ...
                                             VExp_mat(T_index, :), ...
                                             Vip_route, ...
                                             NPrior_mat,...
                                             MExp_mat_95(T_index, :), ...
                                             VExp_mat_95(T_index, :));
    T_index = T_index + 1;
end
NPrior_mat1 = NPrior_mat;
NPrior_mat1(:, 2) = 1./sqrt(NPrior_mat1(:, 2));

%% Full model for learning
Prior_mat = NPrior_mat;
LL = 0; DIC = 0;
for t = T_pre+1: T-1
    display(t);
    [MExp_mat(T_index+1, :), ...
     VExp_mat(T_index+1, :), ...
     NPrior_mat, ...
     MExp_mat_95(T_index+1, :), ...
     VExp_mat_95(T_index+1, :), nLL, nDIC] = KN_BUpdate(T_index, ...
                                             Complete_mat, ...
                                             Prior_mat, ...
                                             MExp_mat(T_index, :), ...
                                             VExp_mat(T_index, :), ...
                                             Vip_route, ...
                                             NPrior_mat,...
                                             MExp_mat_95(T_index, :), ...
                                             VExp_mat_95(T_index, :));
    LL = LL + nLL; DIC = DIC + nDIC;
    T_index = T_index + 1;
end
save Learning_Hier.mat

%% Plot figures for the paper (simple model, n_continuous = 0)
customer = 6; 
figure;
axis = T_pre+1: T; 
plot(axis, MExp_mat((customer-1)*T+axis, 1), 'b--', ...
     axis, MExp_mat((customer-1)*T+axis, 2), 'r:+', ...
     axis, MExp_mat((customer-1)*T+axis, 3), 'g--o', ...
     axis, MExp_mat((customer-1)*T+axis, end), 'k', ...
     'LineWidth',4,'MarkerSize',12);
set(gca,'fontsize',40,'xlim',[25,103],'ylim',[-6,1.5])
legend('Expect mean quality on route a (\mu_{at}^{E})', ...
    'Expect mean quality on route b (\mu_{bt}^{E})', ...
    'Expect mean quality on route c (\mu_{ct}^{E})',...
    'Expect overall mean quality (\mu_{t}^{E})','Location','best');
legend boxoff;
hold on
% plot(Complete_mat(Complete_mat(:, 1)==customer & Complete_mat(:, 3)==1 & Complete_mat(:, 2)>T_pre, 2), ...
%     Complete_mat(Complete_mat(:, 1)==customer & Complete_mat(:, 3)==1 & Complete_mat(:, 2)>T_pre, 4), ...
%     'bo', 'MarkerSize',10);
plot(Complete_mat(Complete_mat(:, 1)==customer & Complete_mat(:, 3)==1 & Complete_mat(:, 2)==62, 2), ...
    Complete_mat(Complete_mat(:, 1)==customer & Complete_mat(:, 3)==1 & Complete_mat(:, 2)==62, 4), ...
    'bo','MarkerSize',20, 'MarkerFaceColor', 'b');
% plot(Complete_mat(Complete_mat(:, 1)==customer & Complete_mat(:, 3)==3 & Complete_mat(:, 2)==83, 2), ...
%     Complete_mat(Complete_mat(:, 1)==customer & Complete_mat(:, 3)==3 & Complete_mat(:, 2)==83, 4), ...
%     'r*', 'MarkerSize',10);
y=get(gca,'ylim');
plot([62,62], y, '--','LineWidth',3);
plot([63,63], y, '--','LineWidth',3);
plot([59,59], y, '--','LineWidth',3);
plot([60,60], y, '--','LineWidth',3);
savefig('Simple Mean Learn');

% figure;
% plot(axis, MExp_mat((customer-1)*T+axis, 3), 'g-.o', ...
%      'LineWidth',3,'MarkerSize',12);
% hold on;
% plot(axis, MExp_mat_95((customer-1)*T+axis, 5), 'r:', ...
%      axis, MExp_mat_95((customer-1)*T+axis, 6), 'r:', ...
%      'LineWidth',4);
% set(gca,'fontsize',40,'xlim',[25,103],'ylim',[-4,3])
% legend('Expect mean quality of route c (\mu_{ct}^{E})',...
%        '95% confidence interval','Location','best');
% legend boxoff;
% y=get(gca,'ylim');
% plot([59,59], y, '--','LineWidth',3);
% plot([60,60], y, '--','LineWidth',3);
% savefig('Simple Mean Learn 95');

RVExp_mat = 1./sqrt(VExp_mat);
figure;
plot(axis, RVExp_mat((customer-1)*T+axis, 1), 'c', ...
     'LineWidth',4,'MarkerSize',12);
hold on;
plot(axis, RVExp_mat((customer-1)*T+axis, 2), 'b:+', ...
     'LineWidth',4,'MarkerSize',12);
set(gca,'fontsize',40,'xlim',[25,103],'ylim',[1.5,2.8])
legend('Experience variability (\sigma^E_t)',...
       'Perception risks (\xi^E_t)','Location','best');
% legend('Experience variability (\sigma^E_t)',...
%     'Location','best');
legend boxoff;
y=get(gca,'ylim');
plot([59,59], y, '--','LineWidth',3);
plot([60,60], y, '--','LineWidth',3);
savefig('Simple Variance Learn');

%% Results for the paper (regression model, n_continuous = 1)
MExp_T = MExp_mat(T:T:end, :);
mean(MExp_T(:, end))
quantile(MExp_T(:, end), [0.05, 0.95])
RVExp_T = RVExp_mat(T:T:end, :);
mean(RVExp_T)
quantile(RVExp_T, [0.05, 0.95])