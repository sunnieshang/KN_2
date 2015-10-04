clc; clearvars; rng('shuffle'); %clf; close all;

T_max = 60; T_min = 10; veggie_max = 20; veggie_min = 12; vip = 99;

%% Simulate Data: based on known parameter using probability model
%  , rather than real optimization based on known errors
% Utility function paramters: 1.eta(satiation) [vip * veggie]

% Note: gamma cannot vary too much, beta can!!!
gamma_mu = normrnd(0,1,[veggie_max,1]);
gamma_sigma = 0.15;
gamma = [normrnd(repmat(gamma_mu',vip,1),gamma_sigma,[vip,veggie_max]),zeros(vip,1)];
% Feature parameters: 1.price; 2.freshness [vip * 2]
pred_num = 2; beta_mu = [-1;1]; beta_sigma = [0.25;0.2];
beta = normrnd(repmat(beta_mu',vip,1),repmat(beta_sigma',vip,1),[vip,pred_num]); 
% NOTE 1: should scall all X var to have mean 0 and std 1
% Note 2: check rcond: <1e-16 is a sig problem: drop or combine var
price = [normrnd(0,1, T_max,veggie_max),zeros(T_max,1)]; % purchase price
pred(:,:,1) = price; 
fresh = mnrnd(1, [0.33, 0.33, 0.34], T_max*veggie_max); 
fresh = sum(fresh .* repmat([-1,0,1],T_max*veggie_max,1),2);
fresh = [reshape(fresh, T_max, veggie_max)*1.3,zeros(T_max,1)];
pred(:,:,2) = fresh; 

%% Build shopping matrix
% 1, trip; 2, vip; 3, choice; 4, veggieid; 5, period; 6, price; 7, fresh
% 8. V; 9, EV; 10; sum(EV) each trip
vip_trip = datasample(T_min:T_max,vip)';
total_trip = sum(vip_trip); 

trip_choice = datasample(veggie_min+1:veggie_max+1,total_trip)'; % +1 represents outside option
vip_choice = zeros(vip,1); 
vip_choice(1) = sum(trip_choice(1:vip_trip(1)));
for i=2:1:vip
    vip_choice(i) = sum(trip_choice(sum(vip_trip(1:i-1))+1:sum(vip_trip(1:i))));
end
tripid = (1:1:total_trip)';
rep_trip = @(k) repmat(tripid(k,:),round(trip_choice(k)),1);
% 1, trip;
matrix(:,1) = cell2mat(arrayfun(rep_trip,(1:length(trip_choice))','UniformOutput',false));
vipid = (1:1:vip)'; 
% 2, vip;
rep_vip =  @(k) repmat(vipid(k,:),round(vip_choice(k)),1);
matrix(:,2) = cell2mat(arrayfun(rep_vip,(1:length(vip_choice))','UniformOutput',false));
% 4, veggieid
matrix(1:trip_choice(1),4) = [sort(randsample(veggie_max, trip_choice(1)-1));21];
for i=2:1:total_trip
    matrix(sum(trip_choice(1:i-1))+1:sum(trip_choice(1:i)),4) = ...
        [sort(randsample(veggie_max,trip_choice(i)-1));21];
end
% 5, period
period = zeros(total_trip,1);
period(1:vip_trip(1)) = sort(randsample(T_max, vip_trip(1)));
for i=2:1:vip
    period(sum(vip_trip(1:i-1))+1:sum(vip_trip(1:i))) = sort(randsample(T_max,vip_trip(i)));
end
rep_period = @(k) repmat(period(k,:),round(trip_choice(k)),1);
matrix(:,5) = cell2mat(arrayfun(rep_period,(1:length(trip_choice))','UniformOutput',false));
% 6, price; 7, fresh
for i=1:sum(trip_choice)
    matrix(i,6) = price(matrix(i,5),matrix(i,4));
    matrix(i,7) = fresh(matrix(i,5),matrix(i,4));
end
 


% 8, indirect utility function V
% 1, trip; 2, vip; 3, choice; 4, veggieid; 5, period; 6, price; 7, fresh
% 8. V; 9, EV; 10, sum(EV) each trip; 11, prob of each trip
matrix(:,8) = gamma(sub2ind(size(gamma),matrix(:,2),matrix(:,4))) +sum( matrix(:,6:7).*beta(matrix(:,2),:),2);
matrix(:,9) = exp(matrix(:,8));
visit_matsparse=sparse((1:size(matrix,1))',matrix(:,1),1);
mid = visit_matsparse'*matrix(:,9);
matrix(:,10) = mid(matrix(:,1));
matrix(:,11) = matrix(:,9)./matrix(:,10);
matrix(1:trip_choice(1),3) = mnrnd(1,matrix(1:trip_choice(1),11));
for i=2:1:total_trip
    matrix(sum(trip_choice(1:i-1))+1:sum(trip_choice(1:i)),3) = ...
        mnrnd(1,matrix(sum(trip_choice(1:i-1))+1:sum(trip_choice(1:i)),11));
end
clear i mid;
save data.mat; 

