%% ==== 'pointingError' ANALYSIS ==== %%
%% Takes X error and Y error to compute pointing error

absList = [0,1]; %absolute = 1, no absolute = 0

for a = 1:length(absList)
  
  absSwitch = absList(a);
  
  if ~absSwitch
    thisVarStr = 'pointingError';
    axisVal_allTargets_y_ttest =     [-10 50];
    axisVal_sideOfSpace_y_ttest =    [-10 30];
    axisVal_allTargets_y_BDST =      [-10 40];
    axisVal_sideOfSpace_y_BDST =     [-10 40];
    
    %% Grab X/Y Error
    [dataX,tmpH] = getData('XError',rawData,sNames);
    [dataY,tmpH] = getData('YError',rawData,sNames);
    
  elseif absSwitch
    thisVarStr = 'pointingError_ABSOLUTE';
    axisVal_allTargets_y_ttest =     [-5 50];
    axisVal_sideOfSpace_y_ttest =    [-5 25];
    axisVal_allTargets_y_BDST =      [-40 40];
    axisVal_sideOfSpace_y_BDST =     [-25 25];
    
    %% Grab X/Y Error
    [dataX,tmpH] = getData_AbsoluteVersion('XError',rawData,sNames);
    [dataY,tmpH] = getData_AbsoluteVersion('YError',rawData,sNames);
    
  end
  
  
  %% Compute distance error (from Rob):
  % sqroot( squ(x error) + squ(y error)  )
  data = [];
  for c = 1:4
    
    tmpX = dataX.targetMean(:,:,c);
    tmpY = dataY.targetMean(:,:,c);
    
    tmpX = tmpX.^2;
    tmpY = tmpY.^2;
    
    tmpD = (tmpX + tmpY);
    
    data.targetMean(:,:,c) = sqrt(tmpD);
    
  end
  
  
  %% Run main deficit tests
  outDir = fullfile('results',thisVarStr);
  try
    rmdir(outDir,'s');
  catch
    %NOOP
  end
  mkdir(outDir)
  
  
  diary(fullfile(outDir,[thisVarStr,'_inputForCrawford-SingleBayes_ES.txt']));
  stats = doCrawfordTtest_allTargets(thisVarStr,data,conditionNames,outDir,axisVal_allTargets_y_ttest);
  stats = doCrawfordTtest_sideOfSpace(thisVarStr,data,conditionNames,outDir,axisVal_sideOfSpace_y_ttest);
  diary OFF
  
  diary(fullfile(outDir,[thisVarStr,'_inputForCrawford-DissocsBayes_ES.txt']));
  plotBDST_allTargets(thisVarStr,data,conditionNames,outDir,axisVal_allTargets_y_BDST);
  plotBDST_sideOfSpace(thisVarStr,data,conditionNames,outDir,axisVal_sideOfSpace_y_BDST);
  diary OFF
  
end