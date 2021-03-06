function plotBDST_sideOfSpace(thisVarStr,data,conditionNames,outDir,axisVal_y)


%% Print BDST data (and Plot), for side of space
fprintf('Printing Crawford BDST Input for SIDE OF SPACE \nVariable:\n%s \n================\n', thisVarStr)

%% gather each condition data
for c = 1:4
  
  currConditionName = conditionNames{c};
  
  controlMean(:,c) = mean(data.targetMean(2:end,:,c));
  controlStd(:,c) = std(data.targetMean(2:end,:,c));
  patientScores(:,c) = data.targetMean(1,:,c);
  nC(:,c) = size(patientScores,2);
  
  %get each control's mean for plotting
  allControls{c} = data.targetMean(2:end,:,c);
  
end
Ncontrols = size(allControls{1},1); %assuming all targets/conditions same!

%% Now collapse Left/Right Space!!
for c = 1:4
  controlMean2(1,c) = mean(controlMean(1:3,c)); %left
  controlMean2(2,c) = controlMean(4,c);         %foveal
  controlMean2(3,c) = mean(controlMean(5:7,c)); %right
  
  controlStd2(1,c) = mean(controlStd(1:3,c)); %left
  controlStd2(2,c) = controlStd(4,c);         %foveal
  controlStd2(3,c) = mean(controlStd(5:7,c)); %right
  
  patientScores2(1,c) = mean(patientScores(1:3,c)); %left
  patientScores2(2,c) = patientScores(4,c);         %foveal
  patientScores2(3,c) = mean(patientScores(5:7,c)); %right
  
  for controls = 1:length(allControls{c})
    allControls2{c}(controls,1) = mean(allControls{c}(controls,1:3)); %left
    allControls2{c}(controls,2) = allControls{c}(controls,4);         %foveal
    allControls2{c}(controls,3) = mean(allControls{c}(controls,5:7)); %right
  end

end
controlMean = controlMean2;
controlStd = controlStd2;
patientScores = patientScores2;
allControls = allControls2;


%Important - 
%setup so good condition first (e.g. RH or Free Vision) to then subtract bad condition
%(e.g. LH or Per Vision). Thus, plotBDST(taskY - TaskX) means that a positive 
%score shows the degree of impairment at LH or at Per Vision
listHand = {'RH','LH'};
listVision = {'FREE','PER'};

%% --- Compare Vision First: free vs per ---%
currHand = [];
currVision = [];
taskX = [];
taskY = [];
rr = [];

for hand = 1:2
  
  currHand = listHand{hand};
  
  fprintf('Comparing Free vs Peripheral for Hand: %s\n===========\n',currHand)
  
  taskX.idx = contain([currHand,listVision{1}],conditionNames);
  taskY.idx = contain([currHand,listVision{2}],conditionNames);
  
  taskX.controlMean   =   controlMean(:,taskX.idx);
  taskX.controlStd    =   controlStd(:,taskX.idx);
  taskX.patientScores =   patientScores(:,taskX.idx);
  taskX.allControls   =   cell2mat(allControls(:,taskX.idx));
  
  taskY.controlMean   =   controlMean(:,taskY.idx);
  taskY.controlStd    =   controlStd(:,taskY.idx);
  taskY.patientScores =   patientScores(:,taskY.idx);
  taskY.allControls   =   cell2mat(allControls(:,taskY.idx));
  
  %%correlation (pearson r) between control performance in taskX & taskY
  for t = 1:length(taskX.patientScores)
    [r,~] = corrcoef(taskX.allControls(:,t),taskY.allControls(:,t));
    rr(t) = r(1,2);
  end
  
  %Print info for Crawford.exe
  fprintf('TaskX = %s   Task Y = %s\n---------\n',listVision{1},listVision{2})
  for t = 1:length(taskX.patientScores)
    fprintf('Current Target: %s\n----------\n',num2str(t))
    fprintf('Control Mean TaskX:        %s\n',num2str(taskX.controlMean(t)))
    fprintf('Control Std TaskX:         %s\n',num2str(taskX.controlStd(t)))
    fprintf('Control Mean TaskY:        %s\n',num2str(taskY.controlMean(t)))
    fprintf('Control Std TaskY:         %s\n',num2str(taskY.controlStd(t)))
    fprintf('Control Corr(TaskX,TaskY): %s\n',num2str(rr(t)))
    fprintf('Control Group N: %s\n',num2str(Ncontrols))
    fprintf('Patient Score TaskX:       %s\n',num2str(taskX.patientScores(t)))
    fprintf('Patient Score TaskY:       %s\n',num2str(taskY.patientScores(t)))
    fprintf('----------\n')
  end
  
  %% plot
  plotBDST(taskX,taskY,Ncontrols)
  pause(0.5)
  
  %% other plot formatting
  titleStr = ['CompareVision-PeripheralSubtractFree-',currHand];
  
  xlabel(['Field of View']);
  ylabel(thisVarStr)
  xlim([0 length(taskX.patientScores)+1]); set(gca,'XTick',[0:1:length(taskX.patientScores)+1]);
  ylim(axisVal_y)
  xticklabels({[],'Left','Foveal','Right'});
  set(gca,'box','off','color','none','TickDir','out','fontsize',25);
  title(titleStr);
  
  %% save plot
  outDir2 = fullfile(outDir,'sideOfSpace_BDST');
  if ~exist(outDir2)
    mkdir(outDir2)
  end
  outName = fullfile(outDir2,[thisVarStr,titleStr]);
  cmdStr = sprintf('export_fig %s.jpg',outName)
  eval(cmdStr);
  
end



%% --- Now Compare Hand : LH vs RH ---%
%strreplace hand/vision
currHand = [];
currVision = [];
taskX = [];
taskY = [];
rr = [];

for vision = 1:2
  
  currVision = listVision{vision};
  
  fprintf('Comparing LH vs RH for Vision: %s\n===========\n',currVision)
  
  taskX.idx = contain([listHand{1},currVision],conditionNames);
  taskY.idx = contain([listHand{2},currVision],conditionNames);
  
  taskX.controlMean   =   controlMean(:,taskX.idx);
  taskX.controlStd    =   controlStd(:,taskX.idx);
  taskX.patientScores =   patientScores(:,taskX.idx);
  taskX.allControls   =   cell2mat(allControls(:,taskX.idx));
  
  taskY.controlMean   =   controlMean(:,taskY.idx);
  taskY.controlStd    =   controlStd(:,taskY.idx);
  taskY.patientScores =   patientScores(:,taskY.idx);
  taskY.allControls   =   cell2mat(allControls(:,taskY.idx));
  
  %%correlation (pearson r) between control performance in taskX & taskY
  for t = 1:length(taskX.patientScores)
    [r,~] = corrcoef(taskX.allControls(:,t),taskY.allControls(:,t));
    rr(t) = r(1,2);
  end
  
  %Print info for Crawford.exe
  fprintf('TaskX = %s   Task Y = %s\n---------\n',listVision{1},listVision{2})
  for t = 1:length(taskX.patientScores)
    fprintf('Current Target: %s\n----------\n',num2str(t))
    fprintf('Control Mean TaskX:        %s\n',num2str(taskX.controlMean(t)))
    fprintf('Control Std TaskX:         %s\n',num2str(taskX.controlStd(t)))
    fprintf('Control Mean TaskY:        %s\n',num2str(taskY.controlMean(t)))
    fprintf('Control Std TaskY:         %s\n',num2str(taskY.controlStd(t)))
    fprintf('Control Corr(TaskX,TaskY): %s\n',num2str(rr(t)))
    fprintf('Control Group N: %s\n',num2str(Ncontrols))
    fprintf('Patient Score TaskX:       %s\n',num2str(taskX.patientScores(t)))
    fprintf('Patient Score TaskY:       %s\n',num2str(taskY.patientScores(t)))
    fprintf('----------\n')
  end
  
  %% plot
  plotBDST(taskX,taskY,Ncontrols)
  pause(0.5)
  %% other plot formatting
  titleStr = ['CompareHand-LHSubtractRH-',currVision];
  
  xlabel(['Field of View']);
  ylabel(thisVarStr)
  xlim([0 length(taskX.patientScores)+1]); set(gca,'XTick',[0:1:length(taskX.patientScores)+1]);
  ylim(axisVal_y)
  xticklabels({[],'Left','Foveal','Right'});
  set(gca,'box','off','color','none','TickDir','out','fontsize',25);
  title(titleStr);
  
  %% save plot
  outDir2 = fullfile(outDir,'sideOfSpace_BDST');
  if ~exist(outDir2)
    mkdir(outDir2)
  end
  outName = fullfile(outDir2,[thisVarStr,titleStr]);
  cmdStr = sprintf('export_fig %s.jpg',outName)
  eval(cmdStr);
  
end

end
