function [ res_nmse, res_acpr, nodpd_nmse, nodpd_acpr ] = dpd_band_limited( par )
% if(1)
%DPD_BAND_LIMITED This function calculates NMSE for bandwidth-limited DPD.
%   Function returns NMSE (dB) for bandwidth-limited DPD with given
%   parameters and for random data in modulated signal with given
%   parameters.

% Authors: Jan Kral <kral.j@lit.cz>, Tomas Gotthans
% Date: 1.1.2017

% determine length of sweep parameter vector
if par.Fb.is_bw_limited && ~par.Tx.is_bw_limited
    % only feedback is band limited
    sweep_len = numel(par.Fb.filt.freq_sweep);
elseif ~par.Fb.is_bw_limited && par.Tx.is_bw_limited
    % only direct path is band limited
    sweep_len = numel(par.Tx.filt.freq_sweep);
elseif ~par.Fb.is_bw_limited && par.Tx.is_bw_limited
    % both feedback and Tx is band limited
    % numel of sweeps has to be same for both
    % sweep parameter can be meshed array
    if numel(par.Fb.filt.freq_sweep) == numel(par.Tx.filt.freq_sweep)
        sweep_len = numel(par.Fb.filt.freq_sweep);
    else
        error('Number of elements in sweep parameters has to be same.');
    end
else
    % no sweeping
    sweep_len = 1;
end

% allocate memory for results
res_nmse = zeros(sweep_len,1);
res_acpr = zeros(sweep_len,length(par.ACPR.chan)/2,2);

% open figure if the plot is required - for live mode
if (par.outs.is_fft_plot)
    h_fig_fft = figure('units','normalized','outerposition',[0 0 1 1]);
end
    
% generate Tx signal
% based on modulation selected
switch par.TxMod.type
    case 'FBMC'
        txSignal0 = FBMC_modulator(par.TxMod.N, par.TxMod.OSR, par.TxMod.Frame);
        txSignal1 = FBMC_modulator(par.TxMod.N, par.TxMod.OSR, par.TxMod.Frame);
    case 'OFDM'
        binaryData = randi([0, 1], par.TxMod.Nbits, 1);
        txSignal0 = modul_ofdm2013(binaryData, par.TxMod.M,...
            par.TxMod.Ncarrier, par.TxMod.NFFT, par.TxMod.GI,...
            par.TxMod.Fnull, par.TxMod.OSR);
        binaryData = randi([0, 1], par.TxMod.Nbits, 1);
        txSignal1 = modul_ofdm2013(binaryData, par.TxMod.M,...
            par.TxMod.Ncarrier, par.TxMod.NFFT, par.TxMod.GI,...
            par.TxMod.Fnull, par.TxMod.OSR);
    case 'QAM'
        binaryData = randi([0, 1], par.TxMod.Nbits, 1);
        txSignal0 = QAM_Modulator(par.TxMod.M, binaryData, par.TxMod.OSR);
        binaryData = randi([0, 1], par.TxMod.Nbits, 1);
        txSignal1 = QAM_Modulator(par.TxMod.M, binaryData, par.TxMod.OSR);
end
txSignal0=txSignal0./max(abs(txSignal0));
txSignal1=txSignal1./max(abs(txSignal1));

for i = 1:sweep_len
    txSignal = txSignal0;
    txSignalEval = txSignal1;
    
    % filter Tx signal if direct path is band-limited
    % Filter in direct path
    if(par.Tx.is_bw_limited)
        if par.Tx.filt.type == 'fir2'
            freq1 = par.Tx.filt.freq_sweep(i) - 0.1;
            freq2 = par.Tx.filt.freq_sweep(i);
            f = [0 freq1/par.TxMod.OSR freq2/par.TxMod.OSR 1]; %freq.band edges
            m = [1  1  0 0];            % Desired amplitudes
            b = fir2(par.Tx.filt.n,f,m);
        elseif par.Tx.filt.type == 'rcos'
            b = getRCosFilter(par.Tx.filt.beta,par.Tx.filt.n,...
                par.Tx.filt.freq_sweep(i), par.TxMod.OSR);
        end
        txSignal=filter(b,1,txSignal);

        % trim the filtered signal due to filter delay
        delay = floor((par.Tx.filt.n-1)/2);
        txSignal=txSignal(1+delay:end);
    end
    
    % Calculate PA model output
    if par.PA.type == 0
        txSignal_PA=PA_Model(txSignal.',par.PA.coef, par.PA.K, par.PA.Q);
    else
        txSignal_PA=DPD_memory_polynomials(txSignal.', par.PA.K, par.PA.Q, par.PA.coef);
    end
    txSignal_PA=(txSignal_PA./max(abs(txSignal_PA))).';
    
    % ---------------------------------------------------------------------
    % Filter in feedback
    b = [];
    if(par.Fb.is_bw_limited)
        if par.Tx.filt.type == 'fir2'
            freq1 = par.Fb.filt.freq_sweep(i) - 0.1;
            freq2 = par.Fb.filt.freq_sweep(i);
            f = [0 freq1/par.TxMod.OSR freq2/par.TxMod.OSR 1]; %freq.band edges
            m = [1  1  0 0];            % Desired amplitudes
            b = fir2(par.Fb.filt.n,f,m);
        elseif par.Tx.filt.type == 'rcos'
            b = getRCosFilter(par.Fb.filt.beta,par.Fb.filt.n,...
                par.Fb.filt.freq_sweep(i), par.TxMod.OSR);
        end
        signal_feedback=filter(b,1,txSignal_PA);
        
        % trim signal due to filter delay
        delay = floor((par.Fb.filt.n-1)/2);
        signal_feedback=signal_feedback(1+delay:end);
        
        % trim other signals
        txSignal = txSignal(1:end-delay);
        txSignal_PA = txSignal_PA(1:end-delay);
    else
        signal_feedback=txSignal_PA;
    end

    % ---------------------------------------------------------------------
    % determine DPD coefficients
    coef=calc_DPD_DDR2(signal_feedback,txSignal,par.DPD.K,par.DPD.Q);

    % ---------------------------------------------------------------------
    % Apply DPD to signal going to amplifier
    
    DPDoutput=DDR2_memory_polynomials(txSignalEval,par.DPD.K,par.DPD.Q,coef);

    % Filter in direct path
    if(par.Tx.is_bw_limited)
        if par.Tx.filt.type == 'fir2'
            freq1 = par.Tx.filt.freq_sweep(i) - 0.1;
            freq2 = par.Tx.filt.freq_sweep(i);
            f = [0 freq1/par.TxMod.OSR freq2/par.TxMod.OSR 1]; %freq.band edges
            m = [1  1  0 0];            % Desired amplitudes
            b = fir2(par.Tx.filt.n,f,m);
        elseif par.Tx.filt.type == 'rcos'
            b = getRCosFilter(par.Tx.filt.beta,par.Tx.filt.n,...
                par.Tx.filt.freq_sweep(i), par.TxMod.OSR);
        end
        DPDoutput=filter(b,1,DPDoutput);
        
        % trim the filtered signal due to filter delay
        delay = floor((par.Tx.filt.n-1)/2);
        DPDoutput=DPDoutput(1+delay:end);
       
        % trim all other signals
        txSignalEval = txSignalEval(1:end-delay);
    end

    % Calculate PA model output
    if par.PA.type == 0
        txSignal_PA_DPD=PA_Model(DPDoutput, par.PA.coef, par.PA.K, par.PA.Q);
    else
        txSignal_PA_DPD=DPD_memory_polynomials(DPDoutput, par.PA.K, par.PA.Q, par.PA.coef);
    end

    % ---------------------------------------------------------------------
    % Evaluation

    % NMSE
    gain=lscov(txSignal_PA_DPD.', txSignalEval);
    res_nmse(i)=nmse(gain.*txSignal_PA_DPD, txSignalEval.');

    % ACPR
    res_acpr(i,:,:) = acpr(txSignal_PA_DPD, par.TxMod.OSR, ...
        par.ACPR.chan,0);

    % plot the results

    if (par.outs.is_AM_plot)
        % plot AM-AM characteristics
        plot(abs(txSignal), abs(txSignal_PA), '.', ...
             abs(txSignalEval), abs(txSignal_PA_DPD), '.')
         drawnow;
    end

    if (par.outs.is_fft_plot)
        % plot FFTs
        psd_tx = 20*log10(abs(fftshift(fft(txSignalEval))));
        psd_PAout = 20*log10(abs(fftshift(fft(txSignal_PA))));
        psd_fb = 20*log10(abs(fftshift(fft(signal_feedback))));
        psd_PA_DPD = 20*log10(abs(fftshift(fft(txSignal_PA_DPD))));
        psd_fb_filter = 20*log10(abs(fftshift(fft([b zeros(1,length(psd_tx)-length(b))]))));
        
        f=rescale_to(1:length(psd_tx), [-par.TxMod.OSR/2,par.TxMod.OSR/2]);
        figure(h_fig_fft);
        plot(f,psd_tx, 'DisplayName','Tx');
        hold on;
        plot(f,psd_PAout, 'DisplayName','PA out');
        plot(f,psd_fb, 'DisplayName','Feedback');
        plot(f,psd_PA_DPD, 'DisplayName','DPD PA out');
        plot(f,psd_fb_filter, 'DisplayName','Filter characteristics');
        hold off;
        legend('show');
        
        drawnow;
    end
end

% -------------------------------------------------------------------------
% calculate NMSE and ACPR for current modulation and amplifier without DPD

% Calculate PA model output
if par.PA.type == 0
    txSignal_PA=PA_Model(txSignal0.',par.PA.coef, par.PA.K, par.PA.Q);
else
    txSignal_PA=DPD_memory_polynomials(txSignal0.', par.PA.K, par.PA.Q, par.PA.coef);
end
txSignal_PA=(txSignal_PA./max(abs(txSignal_PA))).';

% NMSE
gain=lscov(txSignal_PA, txSignal0);
nodpd_nmse=nmse(gain.*txSignal_PA.', txSignal0.');

% ACPR
nodpd_acpr = acpr(txSignal_PA, par.TxMod.OSR, ...
    par.ACPR.chan,0);

end

