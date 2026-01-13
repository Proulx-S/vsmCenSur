clear all
close all
load('~/work/generalPreproc/doIt_generalPreproc/vsmDiamCenSur_indexFile20250630.mat');





dimFiles = cat(1,dir('/local/users/Proulx-S/db/vsm*/*-vsm*/stim/vsmDriven/dim*'),dir('/local/users/Proulx-S/db/vsm*/*-vsm*/stim/log/dim*'));
[~,b,~] = unique({dimFiles.name});
dimFiles = dimFiles(b);
dimFiles([dimFiles.bytes]<20) = [];

% tmp = dir('/local/users/Proulx-S/db/vsmDiamCenSurP1/2024-12-04--bay2--vsmDiamCenSurP1/stim/vsmDriven/dim*');
dt = [];
for i = 1:length(dimFiles)
    tmp = readmatrix(fullfile(dimFiles(i).folder, dimFiles(i).name));
    dt = [dt; diff(tmp(:,2))];
end
figure('MenuBar', 'none', 'ToolBar', 'none');
subplot(1,2,1);
plot(sort(dt))
ylabel('Time between stimulus dim (ms)');
xlabel('sorted stimulus');
grid on
subplot(1,2,2);
histogram(dt,50)
xlabel('Time between stimulus dim (ms)');

mean(dt(dt>800&dt<950))
mean(dt(dt>2200))

min(dt(dt>800))
max(dt(dt>800))



mean(dt)
std(dt)
median(dt)
mode(dt)
range(dt)
iqr(dt)
skewness(dt)
kurtosis(dt)

