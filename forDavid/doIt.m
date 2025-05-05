clear all
close all
cd /home/sebp/work/vsmCenSur/forDavid
load inputTo-getTapers.mat
load inputTo-runFullMT6.mat



%% Compute tapers for a single time post-stimulus window 
t  ; % time vector
% !!! Note the gaps in the time vector
% !!! these are the time points excluded from the analysis
% !!! they are treated as missing data points
% !!! each gap covers the same post-stimulus time period
% !!! so many sub-windows (one per trial) form a single post-stimulus time window
K  ; % number of tapers
tr ; % time resolution
N  ; % number of time points
pad; % padding factor

[tp,eigs,tpDC,N,pad] = getTapers(K,tr,N,t,pad);
tp   ; % time x taper
eigs ; % eigenvalues of the tapers
tpDC ; % don't remember what this is
N    ; % number of time points
pad  ; % padding factor

figure('WindowStyle','docked')
plot(t,tp,'.')


%% Apply to data
d ; % data: time x 1 x 1 x 1 x 1 x voxel
E ; % number of trials
Nw; % number of time points in each sub-window   (E*Nw = N)
f ; % frequency vector
tt = reshape(reshape(t,Nw,E) - onsets,Nw*E,1); % aligning the time vector to 0 at stimulus onset

% reshap for faster computations
ttTmp = permute(reshape(permute(tt ,[3 4 5 6 7 8 1 2]),[R 1 1 1 1 1 N/E E]),[7 8 1 2 3 4 5 6]);
dTmp  = permute(reshape(permute(d ,[3 4 5 6 7 8 1 2]),[R 1 1 V 1 1 N/E E]),[7 8 1 2 3 4 5 6]);
tpTmp = permute(reshape(permute(tp,[3 4 5 6 7 8 1 2]),[1 K 1 1 1 1 N/E E]),[7 8 1 2 3 4 5 6]);
fTmp  = permute(reshape(permute(f ,[3 4 5 6 7 8 1 2]),[1 1 F 1 1 1 1   1]),[7 8 1 2 3 4 5 6]);

J = getJ4(dTmp,tpTmp,ttTmp,fTmp,[],0)/Fs; % [N E R K F V W] = ['time x trial x run x taper x frequency x voxel x window']
J = sum(J,2); % sum over trial sub-windows

%%%% Compute psd
PSD = mean(  conj(J).*J  ,4); % average over tapers



