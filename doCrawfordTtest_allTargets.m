function [stats] = doCrawfordTtest_allTargets(thisVarStr,data,conditionNames,outDir,axisVal_y)


%% Crawford ttests on the seven targets, per condition
fprintf('Crawford Stats for SEVEN TARGETS \n Variable:\n%s \n================\n', thisVarStr)
for c = 1:4
  
  currConditionName = conditionNames{c};
  
  controlMean = mean(data.targetMean(2:end,:,c));
  controlStd = std(data.targetMean(2:end,:,c));
  patientScores = data.targetMean(1,:,c);
  nC = length(data.targetMean(2:end,1)); %assuming patient = row1, and same nC for every target (so use col1)

  %Print info for Crawford.exe
  fprintf('Current Condition: %s\n=========\n',currConditionName)
  fprintf('Control Group N: %s\n-----\n',num2str(nC))
  for t = 1:length(patientScores)
    fprintf('Current Target: %s\n----------\n',num2str(t))
    fprintf('Control Mean: %s\n',num2str(controlMean(t)))
    fprintf('Control Std: %s\n',num2str(controlStd(t)))
    fprintf('Patient Score: %s\n',num2str(patientScores(t)))
    fprintf('\n--------\n')
  end
  
  %get each control's mean for plotting 
  allControls = data.targetMean(2:end,:,c);

  %% Crawford ttest (& plot)
  stats{c} = runCrawford(patientScores,controlMean,controlStd,nC, ...
    1,allControls); %for plot, use 0 for no plot
  pause(0.5)
  
  %% other plot formatting
  xlabel(['Target Position (',char(176),' from midline)']);
  ylabel(thisVarStr)
  xlim([0 length(patientScores)+1]); set(gca,'XTick',[0:1:length(patientScores)+1]);
  ylim(axisVal_y)
  xticklabels({[],'-28','-17','-11','0','11','17','28'});
  set(gca,'box','off','color','none','TickDir','out','fontsize',25);
  title(currConditionName);
  
  %% save plot
  outDir2 = fullfile(outDir,'sevenTargets');
  if ~exist(outDir2)
    mkdir(outDir2)
  end
  outName = fullfile(outDir2,[thisVarStr,'_',currConditionName]);
  cmdStr = sprintf('export_fig %s.jpg',outName)
  eval(cmdStr);
  
  %% print (rough) stats
  disp('two tailed p (per target):')
  disp(stats{c}.p(2,:)') %2 is two-tailed

  %disp('one tailed p (per target):')
  %disp(stats{c}.p(1,:)) %1 is one-tailed

  disp('point estimate of abnormality (per target):')
  disp(stats{c}.p(3,:)') %% point estimate of abnormality (see paper)

  disp('df, tvalue, (per target):')
  disp([stats{c}.df(:),stats{c}.t(:)])

  disp('CI (per target) 1:2 is 95% CI% CI-3:4 is 99%:')
  disp([stats{c}.CI(:,1),stats{c}.CI(:,2),stats{c}.CI(:,3),stats{c}.CI(:,4)]) 

  %% write data for singcar
  mkdir(fullfile(outDir,'csv'))
  writematrix(data.targetMean(:,:,c),fullfile(outDir,'csv',[conditionNames{c},'.csv']),'Delimiter',',')
end
    
end