%load data.mat
%copy this:
%stats=runCrawford(patientScores,controlMean,controlSd,nC,1);

function stats=runCrawford(patientScores,controlMean,controlSd,nC, ...
  plotFig,allControls)

% structure of input
mC=controlMean;%mean 
sC=controlSd;%STD 

nCond=length(mC);%each column is a variable
[c,d]=size(patientScores);%each column is a variable

% check nCond matches for patient + control Data
if(d~=nCond) 
    error('MisMatch N Conditions');
end

%  to estimate
t=zeros(nCond,1);
df=zeros(nCond,1);
p=zeros(nCond,3);  %% has each condition on diff row
CI=zeros(nCond,4); %% each condition on diff. row, 1st 2 num 95%, 2nd two 99% CI

% run crawford independently for each condition of data
for i=1:nCond  
    [t(i),df(i),p(i,:),CI(i,:)]=crawford_tCI(patientScores(i),mC(i),sC(i),nC);
end

% and plot the results with a nice error bar plot
if(plotFig)
     
    CI2=abs(CI-repmat(mC',1,4));
    
    close all
    figure('position',[100,100,1200,1200])
   
    %Crawford cuttoff errorbar
    h=errorbar(1:nCond,mC,CI2(:,1),'Color',[0 0 0],'LineWidth',6,'LineStyle','none')
    hold on
    line(1:nCond,mC,'Color',[0 0 0],'LineWidth',6,'LineStyle','--')
   
    h.CapSize = 24;
    
    %all control lines
    for controlN = 1:length(allControls)
      hold on
      line(1:nCond,allControls(controlN,:),'Color',[0    0.8314    0.9608],'LineWidth',2,'LineStyle','--')
    end
    
    %Patient circle markers
    hold on
    plot(1:nCond,patientScores,'o','MarkerSize',40,'LineWidth',7, ...
      'Color',[1 0 1])
    
end

% output
stats=[];
stats.t=t';
stats.df=df;
stats.p=p';
stats.CI=CI;