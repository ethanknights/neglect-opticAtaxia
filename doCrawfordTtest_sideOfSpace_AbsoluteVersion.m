function [stats] = doCrawfordTtest_sideOfSpace_AbsoluteVersion(thisVarStr,data,conditionNames,outDir,axisVal_y)


%% Crawford ttests on the seven targets, per condition
fprintf('Crawford Stats for Left/Right Side of Space\n Variable:\n%s \n================\n', thisVarStr)
for c = 1:4
  
  currConditionName = conditionNames{c};
  
  controlMean = mean(data.targetMean(2:end,:,c));
  controlStd = std(data.targetMean(2:end,:,c));
  patientScores = data.targetMean(1,:,c);
  nC = size(patientScores,2);
  
  %% Now collapse Left/Right Space!!
  controlMean(1) = mean(controlMean(1:3)); %left
  controlMean(2) = mean(controlMean(5:7)); %right
  controlMean(3:end) = []; %drop leftovers
  
  controlStd(1) = mean(controlStd(1:3)); %left
  controlStd(2) = mean(controlStd(5:7)); %right
  controlStd(3:end) = []; %drop leftovers
  
  patientScores(1) = mean(patientScores(1:3)); %left
  patientScores(2) = mean(patientScores(5:7)); %right
  patientScores(3:end) = []; %drop leftovers 

  %Print info for Crawford.exe
  fprintf('Current Condition: %s\n=========\n',currConditionName)
  fprintf('Control Group N: %s\n-----\n',num2str(nC))
  for t = 1:length(patientScores)
    fprintf('Current Target (1=Left,2=Right): %s\n----------\n',num2str(t))
    fprintf('Control Mean: %s\n',num2str(controlMean(t)))
    fprintf('Control Std: %s\n',num2str(controlStd(t)))
    fprintf('Patient Score: %s\n',num2str(patientScores(t)))
    fprintf('\n--------\n')
  end
  
  %get each control's mean for plotting 
  allControls = data.targetMean(2:end,:,c);
  
  %% Now collapse Left/Right Space!!
  for controls = 1:length(allControls)
    allControls(controls,1) = mean(allControls(controls,1:3)); %left
    allControls(controls,2) = mean(allControls(controls,5:7)); %right
  end
  allControls(:,3:end) = []; %drop leftovers 
  
  %% Crawford ttest (& plot)
  stats{c}= runCrawford(patientScores,controlMean,controlStd,nC, ... %stats{c}= runCrawford_AbsoluteVersion(patientScores,controlMean,controlStd,nC, ... %not working
    1,allControls); %for plot, use 0 for no plot
  title(currConditionName);
  
  %% other plot formatting
  xlabel(['Target Position (',char(176),' from midline)']);
  ylabel(thisVarStr)
  xlim([0 length(patientScores)+1]); set(gca,'XTick',[0:1:length(patientScores)+1]);
  ylim(axisVal_y)
  xticklabels({[],'Left','Right'});
  set(gca,'box','off','color','none','TickDir','out','fontsize',18);
  title(currConditionName);
  
  %% save plot
  outDir2 = fullfile(outDir,'sideOfSpace');
  if ~exist(outDir2)
    mkdir(outDir2)
  end
  outName = fullfile(outDir2,[thisVarStr,'_',currConditionName]);
  cmdStr = sprintf('export_fig %s.png -transparent',outName)
  eval(cmdStr);
  
  h=gcf;
  savefig(h,[outName,'.fig']);
  
  %% print stats
  disp('two tailed p (per side):')
  disp(stats{c}.p(2,:)') %2 is two-tailed

  %disp('one tailed p (per side):')
  %disp(stats{c}.p(1,:)) %1 is one-tailed

  disp('point estimate of abnormality (per side):')
  disp(stats{c}.p(3,:)') %% point estimate of abnormality (see paper)

  disp('df, tvalue, (per side):')
  disp([stats{c}.df(:),stats{c}.t(:)])

  disp('CI (per side) 1:2 is 95% CI% CI-3:4 is 99%:')
  disp([stats{c}.CI(:,1),stats{c}.CI(:,2),stats{c}.CI(:,3),stats{c}.CI(:,4)]) 


end
    
end