close all

NumberOfRunsTotal = 40;


startPos = 60;
endPos = 140;

minLen = endPos;
predictingEndPos = 160;

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

predicting_E_X = zeros(predictingEndPos,1);
predicting_E_X_Squared = zeros(predictingEndPos,1);
numPredicts = 0;

bgAcc_E_X = zeros(minLen,1);
bgAcc_E_X_Squared = zeros(minLen,1);
bgErr_E_X = zeros(minLen,1);
bgErr_E_X_Squared = zeros(minLen,1);
numBgs = 0;

skiped = 0;

isIdChange = zeros(minLen-1,1);
isIdChange_sum_Squared = zeros(minLen-1,1);

for runId = [0:1:NumberOfRunsTotal]
    for i = [0:1:1]
        file = strcat('runs/Collides/run_',num2str(runId),'_objectId_' ,num2str(i) ,'.csv');
        data = csvread(file);
                
        if runId == 8
            
            %continue
        end
        
        figure(13);
        confidence = data(:,3);
        plot(1:length(confidence),confidence);
        if length(confidence) > minLen
            condition = confidence(1:endPos) > 0.2 ;            
            Confidence_E_X = meanConfidence + confidence(1:endPos).*condition;
            Confidence_E_X_Squared = Confidence_E_X_Squared + (confidence(1:endPos).*condition).^2;
            meanConfidence = meanConfidence + confidence(1:endPos).*condition;
            M = M + 1*condition;
        end
        
        %rowsToDelete = any(confidence < 0.2,11);
        %data(rowsToDelete,:) = [];
        
        objNum = data(:,1);
        objId = data(:,2);
        
       
        actualPositionX = data(:,4);
        trackedPositionX = data(:,5);
        actualPositionY = data(:,6);
        trackedPositionY = data(:,7);
        isPredicting = data(:,8);
        
        if length(isPredicting) > predictingEndPos
            predicting_E_X = predicting_E_X + isPredicting(1:predictingEndPos);
            predicting_E_X_Squared = predicting_E_X_Squared + isPredicting(1:predictingEndPos).^2; 
            numPredicts = numPredicts + 1;
        end
        
        actualMotionVectorX = data(:,9);
        trackedMotionVectorX = data(:,10);
        actualMotionVectorY = data(:,11);
        trackedMotionVectorY = data(:,12);
        frameNum = data(:,13);


        errorPositionX = actualPositionX - trackedPositionX;
        errorPositionY = actualPositionY - trackedPositionY;
        errorMotionX = actualMotionVectorX - trackedMotionVectorX;
        errorMotionY = actualMotionVectorY - trackedMotionVectorY;
        
        if max(abs(errorMotionX(60:100))) > 2 || max(abs(errorMotionY(60:100))) > 2
            skiped = skiped + 1;
            continue
        end
        
        
        if length(objId) > minLen+2
            isIdChange = isIdChange + ((objId(2:minLen) - objId(1:endPos-1)) > 0);
            isIdChange_sum_Squared = isIdChange_sum_Squared + ((objId(2:minLen) - objId(1:endPos-1)) > 0).^2;
            NumberOfIdsUsed = NumberOfIdsUsed + 1;
        end
        
        
        hold on
        time = 1:1:length(data);
        if length(data) > minLen - 50
            figure(1);
            plot(time,errorPositionX);
            title('Error X Pos');
            hold on
            figure(2);
            plot(time,errorPositionY);
            title('Error Y Pos');
            hold on
            figure(3);
            plot(time,errorMotionX);
            title('Error X Motion');
            hold on
            figure(4);
            plot(time,errorMotionY);
            title('Error Y Motion');
        end
        
        oldPositionErrorX = agregatorPositionErrorX;
        oldPositionErrorY = agregatorPositionErrorY;
        oldMotionErrorX = agregatorMotionErrorX;
        oldMotionErrorY = agregatorMotionErrorY;
        
        
        if length(time) >minLen
            condition = (confidence(1:endPos) > 0.2) & (max(errorMotionX) < 2) & (max(errorMotionY) < 2); 
            PositionErrorX_E_X  = PositionErrorX_E_X + (errorPositionX(1:endPos)).*condition;
            PositionErrorX_E_X_Squared  = PositionErrorX_E_X_Squared + ((errorPositionX(1:endPos)).*condition).^2;
            PositionErrorY_E_X  = PositionErrorY_E_X + (errorPositionY(1:endPos)).*condition;
            PositionErrorY_E_X_Squared  = PositionErrorY_E_X_Squared + ((errorPositionY(1:endPos)).*condition).^2;
            MotionErrorX_E_X  = MotionErrorX_E_X + (errorMotionX(1:endPos)).*condition;
            MotionErrorX_E_X_Squared  = MotionErrorX_E_X_Squared + ((MotionErrorX_E_X(1:endPos)).*condition).^2;
            MotionErrorY_E_X  = MotionErrorY_E_X + (errorMotionY(1:endPos)).*condition;
            MotionErrorY_E_X_Squared  = MotionErrorY_E_X_Squared + ((MotionErrorY_E_X(1:endPos)).*condition).^2;   
        end
        N = N+1*condition;
    end
    
    
    bgFile = strcat('runs/Collides/run_',num2str(runId),'_background.csv');
    bgData = csvread(bgFile);
    
    bgAccuracy = bgData(:,1);
    bgErrors = bgData(:,2);
    
    if length(bgData) > minLen         
            bgAcc_E_X = bgAcc_E_X + bgAccuracy(1:endPos);
            bgAcc_E_X_Squared = bgAcc_E_X_Squared + (bgAccuracy(1:endPos)).^2;
            bgErr_E_X = bgErr_E_X + bgErrors(1:endPos);
            bgErr_E_X_Squared = bgErr_E_X_Squared + (bgErrors(1:endPos)).^2;
            numBgs = numBgs + 1;
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
bgErrMean = 100 - (bgErr_E_X ./ numBgs)/(600*600);
bgErrVar = ((bgErr_E_X_Squared ./ numBgs) - bgErrMean.^2)/((600*600)^2)*100;


meanPredictPercent = predicting_E_X/ numPredicts;
varPredictPercent = predicting_E_X_Squared/numPredicts - meanPredictPercent.^2;
meanPredictPercent = meanPredictPercent;

figure(5);
plot(startPos:endPos,agregatorPositionErrorX(startPos:endPos));
title('Error X Pos');
figure(6);
hold on;
errorbar(startPos:5:endPos,agregatorPositionErrorX(startPos:5:endPos),sqrt(varPosX(startPos:5:endPos)),'o');
plot(startPos:endPos,agregatorPositionErrorX(startPos:endPos),'r');
xlabel('Frame Number');
ylabel('Error (Pixels)');
xlim([(startPos-1) endPos]);
print -depsc  Collides/ErrorPosX


fPosXMean  = fopen('output/Collides/pos_x_mean.txt','w');
fprintf(fPosXMean,'%4.3f', agregatorPositionErrorX(100));
fclose(fPosXMean);
fPosXVar  = fopen('output/Collides/pos_x_var.txt','w');
fprintf(fPosXVar,'%4.3f', sqrt(varPosX(100)));
fclose(fPosXVar);

figure(7);
plot(startPos:endPos,agregatorPositionErrorY(startPos:endPos));
figure(8);
hold on;
errorbar(startPos:5:endPos,agregatorPositionErrorY(startPos:5:endPos),sqrt(varPosY(startPos:5:endPos)),'o');
plot(startPos:endPos,agregatorPositionErrorY(startPos:endPos),'r');
xlabel('Frame Number');
ylabel('Error (Pixels)');
xlim([(startPos-1) endPos]);
print -depsc  Collides/ErrorPosY


fPosYMean  = fopen('output/Collides/pos_y_mean.txt','w');
fprintf(fPosYMean,'%4.3f', agregatorPositionErrorY(100));
fclose(fPosYMean);
fPosYVar  = fopen('output/Collides/pos_y_var.txt','w');
fprintf(fPosYVar,'%4.3f', sqrt(varPosY(100)));
fclose(fPosYVar);

figure(9);
plot(startPos:endPos,agregatorMotionErrorX(startPos:endPos));


figure(10);
hold on;
errorbar(startPos:5:endPos,agregatorMotionErrorX(startPos:5:endPos),sqrt(varMotionX(startPos:5:endPos)),'o');
plot(startPos:endPos,agregatorMotionErrorX(startPos:endPos),'r');
xlabel('Frame Number');
ylabel('Error (Pixels/Frame)');
xlim([(startPos-1) endPos]);
print -depsc  Collides/ErrorMotionX

fMotionXMean  = fopen('output/Collides/motion_x_mean.txt','w');
fprintf(fMotionXMean,'%4.3f', agregatorMotionErrorX(100));
fclose(fMotionXMean);
fMotionXVar  = fopen('output/Collides/motion_x_var.txt','w');
fprintf(fMotionXVar,'%4.3f', sqrt(varMotionX(100)));
fclose(fMotionXVar);


figure(11);
plot(startPos:endPos,agregatorMotionErrorY(startPos:endPos));

figure(12);
hold on;
errorbar(startPos:5:endPos,agregatorMotionErrorY(startPos:5:endPos),sqrt(varMotionY(startPos:5:endPos)),'o');
plot(startPos:endPos,agregatorMotionErrorY(startPos:endPos),'r');
xlabel('Frame Number');
ylabel('Error (Pixels/Frame)');
xlim([(startPos-1) endPos]);
print -depsc  Collides/ErrorMotionY

fMotionYMean  = fopen('output/Collides/motion_y_mean.txt','w');
fprintf(fMotionYMean,'%4.3f', agregatorMotionErrorY(100));
fclose(fMotionYMean);
fMotionYVar  = fopen('output/Collides/motion_y_var.txt','w');
fprintf(fMotionYVar,'%4.3f', sqrt(varMotionY(100)));
fclose(fMotionYVar);



figure(14);
hold on
plot(startPos:endPos,agregatorPositionErrorX(startPos:endPos));
plot(startPos:endPos,agregatorPositionErrorY(startPos:endPos));
legend('Error in x','Error in y');
xlabel('Frame Number');
ylabel('Average Error (Pixels)');
xlim([(startPos-1) endPos]);
print -depsc  Collides/ErrorPosAgreagate


figure(15);
hold on;
errorbar(startPos:5:endPos,meanConfidence(startPos:5:endPos),sqrt(varConfidence(startPos:5:endPos)),'o');
plot(startPos:endPos,meanConfidence(startPos:endPos));
xlabel('Frame Number');
ylabel('Accuracy');
xlim([startPos-1 endPos]);
print -depsc  Collides/Confidence

fConfidenceMean  = fopen('output/Collides/confidence_mean.txt','w');
fprintf(fConfidenceMean,'%4.1f', 100*meanConfidence(100));
fclose(fConfidenceMean);
fConfidenceVar  = fopen('output/Collides/confidence_var.txt','w');
fprintf(fConfidenceVar,'%4.1f', 100*sqrt(varConfidence(100)));
fclose(fConfidenceVar);

figure(16);
idChange = isIdChange(1:5:length(isIdChange)-5) + isIdChange(2:5:length(isIdChange)-4);
idChange = idChange + isIdChange(3:5:length(isIdChange)-3) + isIdChange(4:5:length(isIdChange)-2) + isIdChange(5:5:length(isIdChange)-1);
idChange = (idChange/5)/NumberOfIdsUsed;
stdIdChange = sqrt(isIdChange_sum_Squared/NumberOfIdsUsed - (isIdChange/NumberOfIdsUsed.^2));

hold on;
%errorbar(1:5:length(stdIdChange),isIdChange(1:5:length(stdIdChange))/NumberOfIdsUsed, stdIdChange(1:5:length(stdIdChange)),'o');
plot(1:5:length(idChange)*5,idChange);
xlabel('Frame Number');
ylabel('Probability of Object Id Change');
print -depsc  Collides/idChange


figure(17);
hold on;
errorbar(1:5:length(bgErrMean),bgErrMean(1:5:length(bgErrMean)), sqrt(bgErrVar(1:5:length(bgErrMean))),'o');
plot(1:length(bgErrMean),bgErrMean,'r');
xlabel('Frame Number');
ylabel('Accuracy');
xlim([(startPos-1) endPos]);
print -depsc  Collides/bgErr

f  = fopen('output/Collides/bgErr_mean_100.txt','w');
fprintf(f,'%4.3f', bgErrMean(100));
fclose(f);
f  = fopen('output/Collides/bgErr_var_100.txt','w');
fprintf(f,'%4.3f', sqrt(bgErrVar(100)));
fclose(f);

f  = fopen('output/Collides/bgErr_mean_60.txt','w');
fprintf(f,'%4.3f', bgErrMean(60));
fclose(f);
f  = fopen('output/Collides/bgErr_var_60.txt','w');
fprintf(f,'%4.3f', sqrt(bgErrVar(60)));
fclose(f);

figure(19);
hold on;
errorbar(1:5:length(meanPredictPercent),meanPredictPercent(1:5:length(meanPredictPercent)), sqrt(varPredictPercent(1:5:length(varPredictPercent))),'o');
plot(1:length(meanPredictPercent),meanPredictPercent,'r');
xlim([-1 predictingEndPos]);
ylim([0,1]);
xlabel('Frame Number');
ylabel('Proportion of Objects being Predicted');
print -depsc  Collides/predicting





NumberOfRunsTotal = NumberOfRunsTotal - round(skiped/2) + 1;
numRuns = fopen('output/Collides/num_runs.txt','w');
fprintf(numRuns,'%.0f',NumberOfRunsTotal);
fclose(numRuns);

