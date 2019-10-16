function analysisDDA(subject,plot,saveFile,saveFigs)
% analysis code for DoubleDrift pre-scan experiment
if nargin < 2 || isempty(plot)
    plot = 1;
end
if nargin < 3 || isempty(saveFile)
    saveFile = 0;
end
if nargin < 4 || isempty(saveFigs)
    saveFigs = 0;
end

rootDir = pathToExpt;
rootDir = [rootDir,'/retinotopy4/DDA/vertical'];

analysisDir = sprintf('%s/analysis',rootDir);
analysisFile = sprintf('%s_flickerControl_analysis_n=%s','group',num2str(length(subject)));
figDir = sprintf('%s/figures',rootDir);

analysis.resp_DD_right = nan(length(subject),1);
analysis.resp_DD_left = nan(length(subject),1);
analysis.resp_ctrl = nan(length(subject),1);
analysis.resp_DD = nan(length(subject),1);
analysis.resp_illusionSize = nan(length(subject),1);
analysis.dataAll = [];

for mm = 1:length(subject)
    DataDir = sprintf('%s/data/%s/',rootDir,subject{mm});
    dataFiles = dir([DataDir,'*.mat']);
    nFiles = length(dataFiles);
    
    analysis.respAll = [];
    analysis.stimCond = [];
    
    for n = 1:nFiles
        dataName = dataFiles(n).name;
        load([DataDir,'/',dataName]);
        analysis.respAll = [analysis.respAll ; td.Resp(:,1)];
        analysis.stimCond = [analysis.stimCond ; td.stimCond];
    end
   
    
    analysis.resp_DD_right(mm,1) = nanmean(analysis.respAll(analysis.stimCond(:,2) == 2)); 
    analysis.resp_DD_left(mm,1) = nanmean(analysis.respAll(analysis.stimCond(:,2) == 1)); 
    analysis.resp_ctrl(mm,1) = nanmean(analysis.respAll(analysis.stimCond(:,1) == 0));
    analysis.resp_DD(mm,1) = nanmean(abs(analysis.respAll(analysis.stimCond(:,1) == 1)));
    analysis.resp_illusionSize(mm,1) = analysis.resp_DD(mm) - analysis.resp_ctrl(mm) ;
    
    analysis.dataAll  = [analysis.dataAll ; repmat(mm,length(analysis.respAll),1),analysis.stimCond, analysis.respAll];

end

analysis.mean_DD_right = mean(analysis.resp_DD_right);
analysis.mean_DD_left = mean(analysis.resp_DD_left);
analysis.mean_ctrl = mean(analysis.resp_ctrl);
analysis.mean_DD = mean(analysis.resp_DD);
analysis.mean_illusionSize = mean(analysis.resp_illusionSize);

analysis.SE_DD_right = std(analysis.resp_DD_right)/sqrt(length(subject));
analysis.SE_DD_left = std(analysis.resp_DD_left)/sqrt(length(subject));
analysis.SE_ctrl = std(analysis.resp_ctrl)/sqrt(length(subject));
analysis.SE_DD = std(analysis.resp_DD)/sqrt(length(subject));
analysis.SE_illusionSize = std(analysis.resp_illusionSize)/sqrt(length(subject));

ts = tinv([0.025  0.975],length(subject)-1);
analysis.CI_DD_right = ts*analysis.SE_DD_right;    
analysis.CI_DD_left= ts*analysis.SE_DD_left;    
analysis.CI_ctrl = ts*analysis.SE_ctrl;    
analysis.CI_DD = ts*analysis.SE_DD;    
analysis.CI_illusionSize = ts*analysis.SE_illusionSize;

if plot
    f(1) = figure('Color','white');
    means1 =  [analysis.mean_DD_right,analysis.mean_DD_left,analysis.mean_ctrl];
    errs1 = zeros([size(means1),2]);
    errs1(:,:,1) = [analysis.CI_DD_right(1),analysis.CI_DD_left(1),analysis.CI_ctrl(1)];
    errs1(:,:,2) = [analysis.CI_DD_right(2),analysis.CI_DD_left(2),analysis.CI_ctrl(2)];
    
    h = barwitherr(errs1,means1);
    set(h,'FaceColor',[0.7,0.7,0.7]);
    set(h,'BarWidth',0.8);
    ylim([-60 60])
    set(gca,'FontName','Arial','FontSize',18);
    ylabel('Degrees adjusted (from vertical)')
    
    err2 = zeros([size(analysis.mean_illusionSize),2]);
    err2(:,:,1) = analysis.CI_illusionSize (1);
    err2(:,:,2) = analysis.CI_illusionSize (2);
    
    f(2) = figure('Color','white');
    h = barwitherr( err2,analysis.mean_illusionSize);
    set(h,'FaceColor',[0.7,0.7,0.7]);
    set(h,'BarWidth',0.3);
    ylim([0 60])
    set(gca,'FontName','Arial','FontSize',18);
    ylabel('Degrees adjusted (from vertical)')
end

[h,p,ci,stats] = ttest(analysis.resp_DD_right, analysis.resp_ctrl);
[h,p,ci,stats] = ttest(analysis.resp_DD_left, analysis.resp_ctrl);
[h,p,ci,stats] = ttest(analysis.resp_DD_right, abs(analysis.resp_DD_left));
[h,p,ci,stats] = ttest(analysis.resp_DD, analysis.resp_ctrl);

if saveFile
    if ~exist (analysisDir,'dir')
        mkdir(analysisDir)
    end
    save(sprintf('%s/%s.mat',analysisDir,analysisFile),'analysis')
    headers = {'subj','condition','internal_motion_direction','response'};
    csvwrite_with_headers('preScanBehavioral_flickerControl_rawData.csv',analysis.dataAll,headers);
    headers_group = {'subj','DD_right','DD_left','Control'};
    csvwrite_with_headers('preScanBehavioral_flickerControl_meanData.csv',[ [1:length(subject)]',analysis.resp_DD_right,analysis.resp_DD_left,analysis.resp_ctrl],headers_group);
end

if saveFigs
    if ~exist (figDir,'dir')
        mkdir(figDir)
    end
    saveAllFigs(f,{'degrees adjusted','illusion size'},analysisFile,figDir,'-depsc');
end

end

