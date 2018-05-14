close all

NumberOfRunsTotal = 30;
numRuns = fopen('output/num_runs.txt','w');
fprintf(numRuns,'%.0f',NumberOfRunsTotal);
fclose(numRuns);

minLen = 200;
N = zeros(minLen,1);
M = zeros(minLen,1);
NumberOfIdsUsed = 0;
meanConfidence = zeros(minLen,1);
Confidence_E_X = zeros(minLen,1);
Confidence_E_X_Squared = zeros(minLen,1);
agregatorPositionErrorX = zeros(minLen,1);
agregatorPositionErrorY = zeros(minLen,1);
agregatorMotionErrorX = zeros(minLen,1);
agregatorMotionErrorY = zeros(minLen,1);

PositionErrorX_E_X = zeros(minLen,1);
PositionErrorX_E_X_Squared = zeros(minLen,1);
PositionErrorY_E_X = zeros(minLen,1);
PositionErrorY_E_X_Squared = zeros(minLen,1);
MotionErrorX_E_X = zeros(minLen,1);
MotionErrorX_E_X_Squared = zeros(minLen,1);
MotionErrorY_E_X = zeros(minLen,1);
MotionErrorY_E_X_Squared = zeros(minLen,1);


bgAcc_E_X = zeros(minLen,1);
bgAcc_E_X_Squared = zeros(minLen,1);
bgErr_E_X = zeros(minLen,1);
bgErr_E_X_Squared = zeros(minLen,1);
numBgs = 0;


perf_E_X = zeros(minLen,1);
perf_E_X_Squared = zeros(minLen,1);
numperfs = 0;

isIdChange = zeros(minLen-1,1);
for runId = [0:1:NumberOfRunsTotal]
    for i = [0:1:2]
        try
            file = strcat('runs/run_',num2str(runId),'_objectId_' ,num2str(i) ,'.csv');
            data = csvread(file);
        catch
            continue
        end
        if runId == 8 && i == 1
            continue
        end
        
        figure(13);
        confidence = data(:,3);
        plot(1:length(confidence),confidence);
        if length(confidence) > minLen
            condition = confidence(1:minLen) > 0.5;            
            Confidence_E_X = meanConfidence + confidence(1:minLen).*condition;
            Confidence_E_X_Squared = Confidence_E_X_Squared + (confidence(1:minLen).*condition).^2;
            meanConfidence = meanConfidence + confidence(1:minLen).*condition;
            M = M + 1*condition;
        end
        
        %rowsToDelete = any(confidence < 0.2,11);
        %data(rowsToDelete,:) = [];
        
        objNum = data(:,1);
        objId = data(:,2);
        
        if length(objId) > minLen+2
            isIdChange = isIdChange + ((objId(2:minLen) - objId(1:minLen-1)) > 0);
            NumberOfIdsUsed = NumberOfIdsUsed + 1;
        end
        
        actualPositionX = data(:,4);
        trackedPositionX = data(:,5);
        actualPositionY = data(:,6);
        trackedPositionY = data(:,7);
        isPredicting = data(:,8);
        actualMotionVectorX = data(:,9);
        trackedMotionVectorX = data(:,10);
        actualMotionVectorY = data(:,11);
        trackedMotionVectorY = data(:,12);
        frameNum = data(:,13);


        errorPositionX = actualPositionX - trackedPositionX;
        errorPositionY = actualPositionY - trackedPositionY;
        errorMotionX = actualMotionVectorX - trackedMotionVectorX;
        errorMotionY = actualMotionVectorY - trackedMotionVectorY;
        
        isLost = (actualPositionX > 600) | (actualPositionY > 600) | ...
            (actualPositionX < 0) | (actualPositionY < 0) | ...
            (abs(errorPositionX) > 60) | (abs(errorPositionY) > 60) | ...
            (abs(errorMotionX) > 2 ) | (abs(errorMotionY) > 2);
        
        hold on
        time = 1:1:length(data);
        if length(data) > minLen - 50
            figure(1);
            plot(time,errorPositionX.*~isLost);
            title('Error X Pos');
            hold on
            figure(2);
            plot(time,errorPositionY.*~isLost);
            title('Error Y Pos');
            hold on
            figure(3);
            plot(time,errorMotionX.*~isLost);
            title('Error X Motion');
            hold on
            figure(4);
            plot(time,errorMotionY.*~isLost);
            title('Error Y Motion');
        end
        
        oldPositionErrorX = agregatorPositionErrorX;
        oldPositionErrorY = agregatorPositionErrorY;
        oldMotionErrorX = agregatorMotionErrorX;
        oldMotionErrorY = agregatorMotionErrorY;
        
        
        
        if length(time) >minLen
            condition = confidence(1:minLen) > 0.5 & (~isLost(1:minLen)); 
            PositionErrorX_E_X  = PositionErrorX_E_X + (errorPositionX(1:minLen)).*condition;
            PositionErrorX_E_X_Squared  = PositionErrorX_E_X_Squared + ((errorPositionX(1:minLen)).*condition).^2;
            PositionErrorY_E_X  = PositionErrorY_E_X + (errorPositionY(1:minLen)).*condition;
            PositionErrorY_E_X_Squared  = PositionErrorY_E_X_Squared + ((errorPositionY(1:minLen)).*condition).^2;
            MotionErrorX_E_X  = MotionErrorX_E_X + (errorMotionX(1:minLen)).*condition;
            MotionErrorX_E_X_Squared  = MotionErrorX_E_X_Squared + ((MotionErrorX_E_X(1:minLen)).*condition).^2;
            MotionErrorY_E_X  = MotionErrorY_E_X + (errorMotionY(1:minLen)).*condition;
            MotionErrorY_E_X_Squared  = MotionErrorY_E_X_Squared + ((MotionErrorY_E_X(1:minLen)).*condition).^2;

        end
        N = N+1*condition;
    end
    
    
    bgFile = strcat('runs/run_',num2str(runId),'_background.csv');
    bgData = csvread(bgFile);
    
    bgAccuracy = bgData(:,1);
    bgErrors = bgData(:,2);
    
    if length(bgData) > minLen         
            bgAcc_E_X = bgAcc_E_X + bgAccuracy(1:minLen);
            bgAcc_E_X_Squared = bgAcc_E_X_Squared + (bgAccuracy(1:minLen)).^2;
            bgErr_E_X = bgErr_E_X + bgErrors(1:minLen);
            bgErr_E_X_Squared = bgErr_E_X_Squared + (bgErrors(1:minLen)).^2;
            numBgs = numBgs + 1;
    end
    
    perfFile = strcat('runs/run_',num2str(runId),'_performance.csv');
    perfData = csvread(perfFile);
    
    perfAccuracy = perfData(:,1);
    
    if length(perfData) > minLen         
            perf_E_X = perf_E_X + perfAccuracy(1:minLen);
            perf_E_X_Squared = perf_E_X_Squared + (perfAccuracy(1:minLen)).^2;
            numperfs = numperfs + 1;
    end
end

agregatorPositionErrorX = PositionErrorX_E_X./N;
agregatorPositionErrorY = PositionErrorY_E_X./N;
agregatorMotionErrorX = MotionErrorX_E_X./N;
agregatorMotionErrorY = MotionErrorY_E_X./N;
varPosX    = PositionErrorX_E_X_Squared./N - agregatorPositionErrorX.^2;
varPosY    = PositionErrorY_E_X_Squared./N - agregatorPositionErrorY.^2;
varMotionX = MotionErrorX_E_X_Squared./N - agregatorMotionErrorX.^2;
varMotionY  = MotionErrorY_E_X_Squared./N - agregatorMotionErrorY.^2;

varConfidence = (Confidence_E_X_Squared./M) - (Confidence_E_X./M).^2;
meanConfidence = meanConfidence./M ;

bgAccMean = bgAcc_E_X ./ numBgs;
bgAccVar = (bgAcc_E_X_Squared ./ numBgs) - bgAccMean.^2;
bgErrMean = 100 - (bgErr_E_X ./ numBgs)/(600*600)*100;
bgErrVar = ((bgErr_E_X_Squared ./ numBgs) - bgErrMean.^2)/((600*600)^2)*100;

perfMean = perf_E_X ./ numperfs;
perfVar = (perf_E_X_Squared ./ numBgs) - perfMean.^2;

figure(5);
plot(1:minLen,agregatorPositionErrorX);
title('Error X Pos');
figure(6);
hold on;
errorbar(1:5:minLen,agregatorPositionErrorX(1:5:minLen),sqrt(varPosX(1:5:minLen)),'o');
plot(1:minLen,agregatorPositionErrorX,'r');
xlabel('Frame Number');
ylabel('Error (Pixels)');
xlim([-1 200]);
print -depsc  ErrorPosX


fPosXMean  = fopen('output/pos_x_mean.txt','w');
fprintf(fPosXMean,'%4.3f', agregatorPositionErrorX(100));
fclose(fPosXMean);
fPosXVar  = fopen('output/pos_x_var.txt','w');
fprintf(fPosXVar,'%4.3f', sqrt(varPosX(100)));
fclose(fPosXVar);

figure(7);
plot(1:minLen,agregatorPositionErrorY);
figure(8);
hold on;
errorbar(1:5:minLen,agregatorPositionErrorY(1:5:minLen),sqrt(varPosY(1:5:minLen)),'o');
plot(1:minLen,agregatorPositionErrorY,'r');
xlabel('Frame Number');
ylabel('Error (Pixels)');
xlim([-1 200]);
print -depsc  ErrorPosY


fPosYMean  = fopen('output/pos_y_mean.txt','w');
fprintf(fPosYMean,'%4.3f', agregatorPositionErrorY(100));
fclose(fPosYMean);
fPosYVar  = fopen('output/pos_y_var.txt','w');
fprintf(fPosYVar,'%4.3f', sqrt(varPosY(100)));
fclose(fPosYVar);

figure(9);
plot(1:minLen,agregatorMotionErrorX);


figure(10);
hold on;
errorbar(1:5:minLen,agregatorMotionErrorX(1:5:minLen),sqrt(varMotionX(1:5:minLen)),'o');
plot(1:minLen,agregatorMotionErrorX,'r');
xlabel('Frame Number');
ylabel('Error (Pixels/Frame)');
xlim([-1 200]);
print -depsc  ErrorMotionX

fMotionXMean  = fopen('output/motion_x_mean.txt','w');
fprintf(fMotionXMean,'%4.3f', agregatorMotionErrorX(100));
fclose(fMotionXMean);
fMotionXVar  = fopen('output/motion_x_var.txt','w');
fprintf(fMotionXVar,'%4.3f', sqrt(varMotionX(100)));
fclose(fMotionXVar);


figure(11);
plot(1:minLen,agregatorMotionErrorY);

figure(12);
hold on;
errorbar(1:5:minLen,agregatorMotionErrorY(1:5:minLen),sqrt(varMotionY(1:5:minLen)),'o');
plot(1:minLen,agregatorMotionErrorY,'r');
xlabel('Frame Number');
ylabel('Error (Pixels/Frame)');
xlim([-1 200]);
print -depsc  ErrorMotionY

fMotionYMean  = fopen('output/motion_y_mean.txt','w');
fprintf(fMotionYMean,'%4.3f', agregatorMotionErrorY(100));
fclose(fMotionYMean);
fMotionYVar  = fopen('output/motion_y_var.txt','w');
fprintf(fMotionYVar,'%4.3f', sqrt(varMotionY(100)));
fclose(fMotionYVar);



figure(14);
hold on
plot(1:minLen,agregatorPositionErrorX(1:minLen));
plot(1:minLen,agregatorPositionErrorY(1:minLen));
legend('Error in x','Error in y');
xlabel('Frame Number');
ylabel('Average Error (Pixels)');
xlim([-1 200]);
print -depsc  ErrorPosAgreagate


figure(15);
hold on;
errorbar(1:5:minLen,meanConfidence(1:5:minLen),sqrt(varConfidence(1:5:minLen)),'o');
plot(1:minLen,meanConfidence);
xlabel('Frame Number');
ylabel('Accuracy');
xlim([-1 200]);
print -depsc  Confidence

fConfidenceMean  = fopen('output/confidence_mean.txt','w');
fprintf(fConfidenceMean,'%4.1f', 100*meanConfidence(100));
fclose(fConfidenceMean);
fConfidenceVar  = fopen('output/confidence_var.txt','w');
fprintf(fConfidenceVar,'%4.1f', sqrt(100*varConfidence(100)));
fclose(fConfidenceVar);

figure(16);
idChange = isIdChange(1:5:length(isIdChange)-5) + isIdChange(2:5:length(isIdChange)-4);
idChange = idChange + isIdChange(3:5:length(isIdChange)-3) + isIdChange(4:5:length(isIdChange)-2) + isIdChange(5:5:length(isIdChange)-1);
idChange = (idChange/5)/NumberOfIdsUsed;
plot(1:5:length(idChange)*5,idChange);
xlabel('Frame Number');
ylabel('Probability of Object Id Change');
print -depsc  idChange


figure(17);
hold on;
errorbar(1:5:length(bgErrMean),bgErrMean(1:5:length(bgErrMean)), sqrt(bgErrVar(1:5:length(bgErrMean))),'o');
plot(1:length(bgErrMean),bgErrMean,'r');
xlabel('Frame Number');
ylabel('Accuracy');
xlim([-1,200]);
print -depsc  bgErr

f  = fopen('output/bgErr_mean_100.txt','w');
fprintf(f,'%4.3f', bgErrMean(100));
fclose(f);
f  = fopen('output/bgErr_var_100.txt','w');
fprintf(f,'%4.3f', sqrt(bgErrVar(100)));
fclose(f);

f  = fopen('output/bgErr_mean_60.txt','w');
fprintf(f,'%4.3f', bgErrMean(60));
fclose(f);
f  = fopen('output/bgErr_var_60.txt','w');
fprintf(f,'%4.3f', sqrt(bgErrVar(60)));
fclose(f);


figure(19);
hold on;
errorbar(1:5:minLen,perfMean(1:5:minLen),sqrt(perfVar(1:5:minLen)),'o');
perfMovingAverage = movmean(perfMean,22);
plot(1:minLen,perfMean,'r');
plot(1:length(perfMovingAverage),perfMovingAverage,'g');
xlabel('Frame Number');
ylabel('FPS');
xlim([19 200]);
print -depsc  performance





