function [stats] = doCrawfordTtest_sideOfSpace(thisVarStr,data,conditionNames,outDir,axisVal_y)


%% Crawford ttests on the 2 sides of space, per condition
%%
%% Note that there are 3 outputs, Left space, Foveal, Right space 
%% Only left/right space are new (i.e. collapsed across 3 targets), whereas
%% foveal is the same 1 target as in '7targets' but included here for plots

fprintf('Crawford Stats for SIDE OF SPACE\n Variable:\n%s \n================\n', thisVarStr)
for c = 1:4
  
  currConditionName = conditionNames{c};
  
  controlMean = mean(data.targetMean(2:end,:,c));
  controlStd = std(data.targetMean(2:end,:,c));
  patientScores = data.targetMean(1,:,c);
  nC = length(data.targetMean(2:end,1));
  
  %% Now collapse Left/Right Space!!
  controlMean(1) = mean(controlMean(1:3)); %left
  controlMean(2) = controlMean(4);         %foveal
  controlMean(3) = mean(controlMean(5:7)); %right
  controlMean(4:end) = []; %drop leftovers
  
  controlStd(1) = mean(controlStd(1:3)); %left
  controlStd(2) = controlStd(4);         %foveal
  controlStd(3) = mean(controlStd(5:7)); %right
  controlStd(4:end) = []; %drop leftovers
  
  patientScores(1) = mean(patientScores(1:3)); %left
  patientScores(2) = patientScores(4);         %foveal  
  patientScores(3) = mean(patientScores(5:7)); %right
  patientScores(4:end) = []; %drop leftovers 

  %Print info for Crawford.exe
  fprintf('Current Condition: %s\n=========\n',currConditionName)
  fprintf('Control Group N: %s\n-----\n',num2str(nC))
  for t = 1:length(patientScores)
    fprintf('Current Target (1=Left,2=Foveal,3=Right): %s\n----------\n',num2str(t))
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
    allControls(controls,2) = allControls(controls,4);         %foveal 
    allControls(controls,3) = mean(allControls(controls,5:7)); %right
  end
  allControls(:,4:end) = []; %drop leftovers 
  
  %% Crawford ttest (& plot)
  stats{c}= runCrawford(patientScores,controlMean,controlStd,nC, ...
    1,allControls); %for plot, use 0 for no plot
  title(currConditionName);
  pause(0.5)
  
  %% other plot formatting
  xlabel(['Field of View']);
  ylabel(thisVarStr)
  xlim([0 length(patientScores)+1]); set(gca,'XTick',[0:1:length(patientScores)+1]);
  ylim(axisVal_y)
  xticklabels({[],'Left','Foveal','Right'});
  set(gca,'box','off','color','none','TickDir','out','fontsize',25);
  title(currConditionName);
  
  %% save plot
  outDir2 = fullfile(outDir,'sideOfSpace');
  if ~exist(outDir2)
    mkdir(outDir2)
  end
  outName = fullfile(outDir2,[thisVarStr,'_',currConditionName]);
  cmdStr = sprintf('export_fig %s.jpg',outName)
  eval(cmdStr);
  
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

  %% write data for singcar
  mkdir(fullfile(outDir,'csv'))
  writematrix(data.targetMean(:,:,c),fullfile(outDir,'csv',[conditionNames{c},'.csv']),'Delimiter',',')
end
    
end