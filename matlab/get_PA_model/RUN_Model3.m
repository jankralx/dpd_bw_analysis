% Modeling USRP RACOM PA
clc
clear all
close all
addpath('Utils');

load('Data/Data_V2.mat');
%Normalizations
txSignal=Input_Data./max(abs(Input_Data));
signal_feedback=Feedback_Data./max(abs(Feedback_Data));
                       
clear Input Feedback_Data;

%---------------------------------------------------------------------------
%Modeling PA
K=9;
Q=1;
coef=calc_DPD(txSignal,signal_feedback,K,Q);
txSignal_PA=DPD_memory_polynomials(txSignal,K,Q,coef);
%---------------------------------------------------------------------------
e=nmse(txSignal_PA, signal_feedback);
disp(['Error= ', num2str(e),' dB']);

plot(abs(txSignal), abs(txSignal_PA),'.', abs(txSignal), abs( signal_feedback),'.')

psd1=10*log10(abs(fftshift(fft(txSignal))));
f=rescale_to(1:length(psd1), [-1,1]);
figure
plot(f,psd1);
hold on
plot(f,10*log10(abs(fftshift(fft(signal_feedback)))));
plot(f,10*log10(abs(fftshift(fft(txSignal_PA)))));
