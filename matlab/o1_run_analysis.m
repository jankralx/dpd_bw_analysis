% Authors: Jan Kral <kral.j@lit.cz>
% Date: 16.1.2017

% this scripts run the analysis provided in the conference paper

clear all;

addpath('Utils');
addpath('get_PA_model');    % for PA_model extraction

is_test = 0;                % no sweeps, only single evaluation

Nrep = 20;   % number of repetitions to avoid randomness of Tx data

% -------------------------------------------------------------------------
% Input parameters settings

% PA parameters
par.PA.type = 0;        % declare that the PAmodel function is used
par.PA.coef = [ 0.509360227527429 + 1.09524853022532i;...
               -0.0992873613403637 - 0.170261849774516i;...
               -0.0347754375003473 - 0.0247212149015436i;...
               -0.00353320874772281 - 0.00211119148781448i;...
               0.00260430842062743 - 0.00429101487393531i;...
               0.00320810224865987 - 0.000580829859014498i;...
               -0.000816817963483357 + 0.000357784194921971i];
par.PA.K = 7;
par.PA.Q = 0;

% DPD parameters
par.DPD.K = 7;
par.DPD.Q = 0;

% Filters
% -------

% feedback
par.Fb.is_bw_limited = 0;
par.Fb.filt.type = 'rcos'; % 'rcos' | 'fir2';
par.Fb.filt.beta = 0.1; % raised-cosine filter roll-off factor
par.Fb.filt.n = 81;    % feedback filter order
par.Fb.filt.freq = [];  

% Tx path
par.Tx.is_bw_limited = 0;
par.Tx.filt.type = 'rcos'; % 'rcos' | 'fir2';
par.Tx.filt.beta = 0.1; % raised-cosine filter roll-off factor
par.Tx.filt.n = 81;    % direct path filter order
par.Tx.filt.freq = []; 

% -------

% Outputs
par.outs.is_AM_plot = 0;
par.outs.is_fft_plot = 0;

% ACPR channels definition
par.ACPR.chan = [1/2+0.1, 3/2+0.1,...
                 3/2+0.2, 5/2+0.2,...
                 5/2+0.3, 7/2+0.3];
             
% create parameter cell array for different modulation schemes
% 1st dimension - modulation
pars = {par; par; par; par};

% FBMC Modulator
pars{1}.TxMod.name = 'FBMC';
pars{1}.TxMod.type = 'FBMC';
pars{1}.TxMod.N = 1024; % Num of SUBCHANNELS
pars{1}.TxMod.OSR = 8;  % Oversampling
pars{1}.TxMod.Frame = 1;

% OFDM Modulator
pars{2}.TxMod.name = 'OFDM';
pars{2}.TxMod.type = 'OFDM';
pars{2}.TxMod.Ncarrier = 1024;
pars{2}.TxMod.NFFT = 1024;
pars{2}.TxMod.M = 4;
pars{2}.TxMod.Nbits = pars{2}.TxMod.Ncarrier*log2(pars{2}.TxMod.M)*4;
pars{2}.TxMod.Fnull = 0;
pars{2}.TxMod.GI = 246/1000;
pars{2}.TxMod.OSR = 8;

% QPSK Modulator
pars{3}.TxMod.name = 'QPSK';
pars{3}.TxMod.type = 'QAM';
pars{3}.TxMod.M = 4;
pars{3}.TxMod.Nbits = 2000*log2(pars{3}.TxMod.M);
pars{3}.TxMod.OSR = 8;

% QAM16 Modulator
pars{4}.TxMod.name = 'QAM16';
pars{4}.TxMod.type = 'QAM';
pars{4}.TxMod.M = 16;
pars{4}.TxMod.Nbits = 2000*log2(pars{3}.TxMod.M);
pars{4}.TxMod.OSR = 8;



if (is_test)
    [res_nmse, res_acpr] = dpd_band_limited(par);
    return;             % do not continue
end

% allocate memory for results
res = cell(size(pars));


% loop through all modulations
tic
for k = 1:numel(pars)
    % -------------------------------------------------------------------------
    % Sweep the feedback bandwidth
    par = pars{k};          % load parameters for current modulation
    par.Fb.is_bw_limited = 1;   % enable the feedback filter
    
    sweep_par_fb = [0.3:0.1:2.8 3:0.5:6];
    par.Fb.filt.freq_sweep = sweep_par_fb;

    % allocate memory for results
    res{k}.fb.nmse = zeros(Nrep,length(sweep_par_fb));
    res{k}.fb.acpr = zeros(Nrep,length(sweep_par_fb),length(par.ACPR.chan)/2,2);
    res{k}.nodpd_fb.nmse = zeros(Nrep,1);
    res{k}.nodpd_fb.acpr = zeros(Nrep,length(par.ACPR.chan)/2,2);

    for i = 1:Nrep
        % calculate DPD results for sweep parameter and for all repetitions
        [res{k}.fb.nmse(i,:), res{k}.fb.acpr(i,:,:,:), ...
         res{k}.nodpd_fb.nmse(i,:), res{k}.nodpd_fb.acpr(i,:,:)] = dpd_band_limited(par);

        progress_text(i/Nrep, ...
            sprintf('Sweeping feedback bandwidth (%i/%i)', ...
            2*k-1,2*numel(pars)));
    end

    % -------------------------------------------------------------------------
    % Sweep the Tx bandwidth
    par = pars{k};          % load parameters for current modulation
    par.Tx.is_bw_limited = 1;   % enable the direct path filter

    sweep_par_dp = [1 1.2 1.4:0.2:3.6 4:0.5:6];
    par.Tx.filt.freq_sweep = sweep_par_dp;

    % allocate memory for results
    res{k}.dp.nmse = zeros(Nrep,length(sweep_par_dp));
    res{k}.dp.acpr = zeros(Nrep,length(sweep_par_dp),length(par.ACPR.chan)/2,2);
    res{k}.nodpd_dp.nmse = zeros(Nrep,1);
    res{k}.nodpd_dp.acpr = zeros(Nrep,length(par.ACPR.chan)/2,2);
    
    for i = 1:Nrep
        % calculate DPD results for sweep parameter and for all repetitions
        [res{k}.dp.nmse(i,:), res{k}.dp.acpr(i,:,:,:), ...
         res{k}.nodpd_dp.nmse(i), res{k}.nodpd_dp.acpr(i,:,:)] = dpd_band_limited(par);

        progress_text(i/Nrep, ...
            sprintf('Sweeping direct path bandwidth (%i/%i)', ...
            2*k,2*numel(pars)));
    end

end
toc