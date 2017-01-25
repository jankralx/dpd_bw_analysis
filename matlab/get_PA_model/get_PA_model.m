function [ coef, name ] = get_PA_model( type, K, Q )
%GET_PA_MODEL Summary of this function goes here
%   Detailed explanation goes here

if type == 0
    % type 0 is only for K = 7 and Q = 0
    if K == 7 && Q == 0
        name = 'PA0';
        coef = [ 0.509360227527429 + 1.09524853022532i;
               -0.0992873613403637 - 0.170261849774516i;
               -0.0347754375003473 - 0.0247212149015436i;
               -0.00353320874772281 - 0.00211119148781448i;
               0.00260430842062743 - 0.00429101487393531i;
               0.00320810224865987 - 0.000580829859014498i;
               -0.000816817963483357 + 0.000357784194921971i];
        return;
    else
        error('Type 0 is for K = 7 and Q = 0 only');
    end
elseif type >= 1 && type <= 3
    switch type
        case 1
            % model of PA NXP_BLF8888A_75W
            name = 'NXP_BLF8888A_75W';
            in = importdata('Doherty_NXP_BLF8888A_75W_B2.txt');
        case 2
            % model of PA Doherty 666 MHz
            name = 'Doherty_666MHz';
            in = importdata('AmpliDoherty_666MHz_BW8_acq6.txt');
        case 3
            % model of Doherty 120W
            name = 'Doherty_120W';
            in = importdata('Doherty_NXP_BLF8888B_120W_B1.txt');
    end
    
    % parse Tx signal and feedback signal from loaded data
    txSignal=(in(1:end,1)+1i.*in(1:end,2));
    txSignal=txSignal/max(abs(txSignal));

    signal_feedback=(in(1:end,3)+1i.*in(1:end,4));
    signal_feedback=signal_feedback/max(abs(signal_feedback));
    clear in      

elseif type == 4
    % Model of USRP RACOM PA
    name = 'PA_USRP_RACOM';
    load('Data_V2.mat');
    %Normalizations
    txSignal=Input_Data./max(abs(Input_Data));
    signal_feedback=Feedback_Data./max(abs(Feedback_Data));

    clear Input Feedback_Data;
else
    error('Given type of amplifier is not supported');
end

coef=calc_DPD(txSignal,signal_feedback,K,Q);

end

