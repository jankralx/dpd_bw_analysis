% Authors: Jan Kral <kral.j@lit.cz>
% Date: 16.1.2017

% this script plots calculated results of o1_run_analysis.m script
close all;

if ~exist('figures', 'dir')
    mkdir('figures')
end

if 0    % save figures when 1
    save_formats = {'.png';'.pdf'};     % save formats. make empty not to save
else
    save_formats = [];
end

addpath('Utils');

% define default colors  for plots
colors = [
         0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0         0.5       0
    0.4940    0.1840    0.5560
    0.9290    0.6940    0.1250
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
    ];

markers = ['x'; 'o'; 's'; '^'; '+'; '*'];

% plot NMSE for feedback for all modulation scheemes
hfig = figure();
set(gcf, 'Position', [0 0 600 400]);
subplot(1,2,1);
for mod_i = 1:size(pars,1)
    hold on;
    plot(sweep_par_fb, avg_dB(res{mod_i}.fb.nmse,1,10), ...
        'Marker',markers(mod_i),...
        'LineStyle','-',...
        'Color',colors(mod_i,:), ...
        'DisplayName',pars{mod_i}.TxMod.name);
    hold off;
end
title('\textbf{a) NMSE for limited FB}');
xlabel('$B_{FB}$ (-)');
ylabel('NMSE (dB)');
legend('show');
axis([0.5 4, -50 -10]);
grid on;

% plot marks of NMSE without DPD for all modulations
for mod_i = 1:size(pars,1)
    nmse_nodpd = avg_dB(res{mod_i}.nodpd_fb.nmse,1,10);
    hold on;
    plot([0 6], [nmse_nodpd nmse_nodpd], 'Color',colors(mod_i,:), ...
        'LineStyle','--');
    plot(3+mod_i*0.2, nmse_nodpd, 'Marker',markers(mod_i),...
        'MarkerSize',10, 'Color',colors(mod_i,:));
    hold off;
end

% save figure
ApplyFigureSettings(gcf);
name = sprintf('figures/01_fb_nmse');
for form_ind = 1:size(save_formats,1)
    saveas(gcf, sprintf('%s%s', name, save_formats{form_ind}));
end


% feedback filter - ACPR - 1st channel
figure();
for mod_i = 1:size(pars,1)    
    % avarage repetitions and upper and lower channels
    acpr_fb_avg = avg_dB(avg_dB(res{mod_i}.fb.acpr,4,10),1,10);
    acpr_fb_avg = reshape(acpr_fb_avg,size(acpr_fb_avg,2),size(acpr_fb_avg,3));

    hold on;
    plot(sweep_par_fb, acpr_fb_avg(:,1),'Marker',markers(mod_i),  'Color',colors(mod_i,:), 'DisplayName', sprintf('%s',pars{mod_i}.TxMod.name));
    hold off;
end
title(sprintf('ACPR  1st adjacent channel for linearised PA\nwith band-limited feedback'));
xlabel('B_{FB} (-)');
ylabel('ACPR (dB)');
legend('show');
axis([0.5 4, -30 -10]);
grid on;

% feedback filter - ACPR - 2nd channel
figure();
for mod_i = 1:size(pars,1)    
    % avarage repetitions and upper and lower channels
    acpr_fb_avg = avg_dB(avg_dB(res{mod_i}.fb.acpr,4,10),1,10);
    acpr_fb_avg = reshape(acpr_fb_avg,size(acpr_fb_avg,2),size(acpr_fb_avg,3));

    hold on;
    plot(sweep_par_fb, acpr_fb_avg(:,2),'Marker',markers(mod_i), 'Color',colors(mod_i,:), 'DisplayName', sprintf('%s',pars{mod_i}.TxMod.name));
    hold off;
end
title('ACPR for 2nd adj. channel for linearised PA with band-limited feedback');
xlabel('B_{FB} (-)');
ylabel('ACPR (dB)');
legend('show');
axis([0 3.5, -35 0]);
grid on;


% direct path filter - NMSE
figure(hfig);
subplot(1,2,2);

for mod_i = 1:size(pars,1)
    hold on;
    plot(sweep_par_dp, avg_dB(res{mod_i}.dp.nmse,1,10),...
        'Marker',markers(mod_i),...
        'LineStyle','-',...
        'Color',colors(mod_i,:), ...
        'DisplayName',pars{mod_i}.TxMod.name);
    hold off;
end
title('\textbf{b) NMSE for limited DP}');
xlabel('$B_{DP}$ (-)');
ylabel('NMSE (dB)');
legend('show');
axis([1 4, -50 -10]);
grid on;

% plot marks of NMSE without DPD for all modulations
for mod_i = 1:size(pars,1)
    nmse_nodpd = avg_dB(res{mod_i}.nodpd_dp.nmse,1,10);
    hold on;
    plot([0 6], [nmse_nodpd nmse_nodpd], 'Color',colors(mod_i,:), ...
        'LineStyle','--');
    plot(3+mod_i*0.2, nmse_nodpd, 'Marker',markers(mod_i),...
        'MarkerSize',10, 'Color',colors(mod_i,:));
    hold off;
end

% save figure
ApplyFigureSettings(gcf);
name = sprintf('figures/04_dp_nmse');
for form_ind = 1:size(save_formats,1)
    saveas(gcf, sprintf('%s%s', name, save_formats{form_ind}));
end


% direct path filter - ACPR - 1st channel
figure();
set(gcf, 'Position', [0 0 600 400]);

ellipse_pos_i = 6;
ellipse_y_max = -inf;
ellipse_y_min = inf;

for mod_i = 1:size(pars,1)
    % each adjacent channel into single figure
    acpr_dp_avg = avg_dB(avg_dB(res{mod_i}.dp.acpr,4,10),1,10);
    acpr_dp_avg = reshape(acpr_dp_avg,size(acpr_dp_avg,2),size(acpr_dp_avg,3));

    hold on;
    plot(sweep_par_dp, acpr_dp_avg(:,1),'Marker',markers(mod_i), 'Color',colors(mod_i,:), 'DisplayName',pars{mod_i}.TxMod.name);
    hold off;
    
    ellipse_y_max = max([ellipse_y_max, acpr_dp_avg(ellipse_pos_i,1)]);
    ellipse_y_min = min([ellipse_y_min, acpr_dp_avg(ellipse_pos_i,1)]);
end
legend('show');

% draw ellipse to distinguish the 1st channel
t = linspace(0,2*pi);
delta_x = 0.2;
delta_y = (ellipse_y_max - ellipse_y_min)+1;
pos_x = sweep_par_dp(ellipse_pos_i);
pos_y = (ellipse_y_max + ellipse_y_min)/2;
hold on;
plot(delta_x/2*cos(t) + pos_x, delta_y/2*sin(t) + pos_y,'k');
hold off;

% plot line and text
t = deg2rad(75);
x1 = delta_x/2*cos(t) + pos_x;
y1 = delta_y/2*sin(t) + pos_y;
x2 = x1 + 0.1;
y2 = y1 + 1;
hold on;
plot([x1, x2], [y1, y2], 'k');
hold off;
text(x2+0.05,y2, '1st adj. channel');


% direct path filter - ACPR - 2nd channel
%figure();

ellipse_pos_i = 15;
ellipse_y_max = -inf;
ellipse_y_min = inf;

for mod_i = 1:size(pars,1)
    % each adjacent channel into single figure
    acpr_dp_avg = avg_dB(avg_dB(res{mod_i}.dp.acpr,4,10),1,10);
    acpr_dp_avg = reshape(acpr_dp_avg,size(acpr_dp_avg,2),size(acpr_dp_avg,3));

    hold on;
    plot(sweep_par_dp, acpr_dp_avg(:,2),'Marker',markers(mod_i), 'Color',colors(mod_i,:), 'DisplayName',pars{mod_i}.TxMod.name);
    hold off;
    
    ellipse_y_max = max([ellipse_y_max, acpr_dp_avg(ellipse_pos_i,2)]);
    ellipse_y_min = min([ellipse_y_min, acpr_dp_avg(ellipse_pos_i,2)]);
end
% title(sprintf('ACPR for 1st and 2nd adjacent channels for linearised PA\nwith band-limited direct path'));
title('\textbf{ACPR for linearised PA with band-limited direct path}');
xlabel('$B_{DP}$ (-)');
ylabel('ACPR (dB)');
% legend('show', 'Location', 'southeast');
axis([1 6, -36 -18]);
grid on;


% draw ellipse to distinguish the 2nd channel
t = linspace(0,2*pi);
delta_x = 0.2;
delta_y = (ellipse_y_max - ellipse_y_min)+1;
pos_x = sweep_par_dp(ellipse_pos_i);
pos_y = (ellipse_y_max + ellipse_y_min)/2;
hold on;
plot(delta_x/2*cos(t) + pos_x, delta_y/2*sin(t) + pos_y,'k');
hold off;

% plot line and text
t = deg2rad(-90);
x1 = delta_x/2*cos(t) + pos_x;
y1 = delta_y/2*sin(t) + pos_y;
x2 = x1 + 0.1;
y2 = y1 - 1.5;
hold on;
plot([x1, x2], [y1, y2], 'k');
hold off;
text(x2+0.05,y2, '2nd adj. channel');

% save figure
ApplyFigureSettings(gcf);
name = sprintf('figures/05_dp_acpr_1st_2nd');
for form_ind = 1:size(save_formats,1)
    saveas(gcf, sprintf('%s%s', name, save_formats{form_ind}));
end


