#include "stdafx.h"
#include "Evaluator.h"
#define VideoWidth 600
#define VideoHeight 600

Evaluator::Evaluator()
{
}


Evaluator::~Evaluator()
{
}

void Evaluator::evaluateSegments(Shape** actualShapes, int numShapes, TrackedObjects trackedShapes,int runId,int frameNum,Mat bg,VideoSource vs,double frameRate,String outputFolder)
{
	int numTrackedShapes = trackedShapes.getNumTrackedObjects();
	for (int i = 0; i < numShapes; i++) {
		int bestMatchIndex=-1;
		double bestMatchValue=-1;
		for (int j = 0; j < numTrackedShapes; j++) {
			double similarity = evaluateSegmentsSimalarity(actualShapes[i], trackedShapes.getTrackedObject(j));
			if (bestMatchValue < similarity) {
				bestMatchIndex = j;
				bestMatchValue = similarity;
			}
		}
		std::cout << "Similarity Actual: " + SSTR(i) + " Tracked: " + SSTR(bestMatchIndex) + "is" + SSTR(bestMatchValue) + "\n";
		ofstream objfile(outputFolder+"\\run_"+SSTR(runId)+"_objectId_"+SSTR(i)+".csv",ios::app);
		if (objfile.is_open())
		{
			if (bestMatchIndex > -1) {
				objfile << SSTR(bestMatchIndex) + "," + SSTR(trackedShapes.getTrackedObject(bestMatchIndex)->getId()) + "," + SSTR(bestMatchValue) + ",";
				objfile << SSTR(actualShapes[i]->getX()) + "," + SSTR(trackedShapes.getTrackedObject(bestMatchIndex)->getPosition().val[0]) + ",";
				objfile << SSTR(actualShapes[i]->getY()) + "," + SSTR(trackedShapes.getTrackedObject(bestMatchIndex)->getPosition().val[1]) + ",";
				objfile << SSTR(trackedShapes.getTrackedObject(bestMatchIndex)->isPredicting()) + ",";
				objfile << SSTR(actualShapes[i]->getMotionVector()[0]) + ",";
				objfile << SSTR(trackedShapes.getTrackedObject(bestMatchIndex)->getMotionVector().val[0]) + ",";
				objfile << SSTR(actualShapes[i]->getMotionVector()[1]) + ",";
				objfile << SSTR(trackedShapes.getTrackedObject(bestMatchIndex)->getMotionVector().val[1]) + ",";
				objfile << SSTR(frameRate);
			}
			objfile <<	"\n";
			objfile.close();
		}
		else cout << "Unable to open obj eval file";
	}

	ofstream bgfile(outputFolder+"\\run_" + SSTR(runId) + "_background.csv", ios::app);
	if (bgfile.is_open())
	{
		Mat backgroundAbsDiff;
		Mat actualBackground;
		vs.getBackground().copyTo(actualBackground);
		absdiff(bg, actualBackground, backgroundAbsDiff);
		cvtColor(backgroundAbsDiff, backgroundAbsDiff, CV_BGR2GRAY);
		double accuracy = 1 - sum(backgroundAbsDiff)[0] / (backgroundAbsDiff.rows*backgroundAbsDiff.cols*255*255);
		threshold(backgroundAbsDiff, backgroundAbsDiff, 1, 1, CV_THRESH_BINARY);
		double numIncorrectPixels = sum(backgroundAbsDiff)[0];
		bgfile << SSTR(accuracy)+","+ SSTR(numIncorrectPixels)+"\n";
	}
	else cout << "Unable to open bg eval file";

	bgfile.close();

	ofstream perffile(outputFolder+"\\run_" + SSTR(runId) + "_performance.csv", ios::app);
	if (perffile.is_open())
	{
		perffile << SSTR(frameRate) + "\n";
	}
	else cout << "Unable to open bg eval file";

	perffile.close();


	std::cout << "\n";
}


double Evaluator::evaluateSegmentsSimalarity(Mat actualShape, Mat object,Rect2d roi) {
	Mat output, grey, shape, shapeObject, finalOutput(object.size(), object.type());
	Mat mask, preMask;

	shape = actualShape;
	shapeObject = object;
	absdiff(shape, shapeObject, output);
	cvtColor(output, grey, CV_BGR2GRAY);
	cvtColor(actualShape, preMask, CV_BGR2GRAY);

	threshold(preMask, mask, 0, 255, THRESH_BINARY);
	grey.copyTo(finalOutput, mask);

	return 1 - sum(finalOutput(roi))[0] / (sum(mask)[0]);
	
}

double Evaluator::evaluateSegmentsSimalarity(Shape* actualShape, TrackedObject* object)
{
	Mat output,grey,shape,shapeObject,finalOutput(object->getObjectMat().size(),object->getObjectMat().type());
	Mat mask,preMask;
	/*matchTemplate(object->getObjectMat(), actualShape->getShapeFrameMat(), output, TM_CCOEFF_NORMED);
	double min, max;
	minMaxLoc(output,&min,&max);
	return max;*/
	shape = actualShape->getShapeFrameMat();
	shapeObject = object->getOnlyObjectMat();
	imshow("shape", shape);
	imshow("shapeObj", shapeObject);
	absdiff(shape, shapeObject,output);

	imshow("absdif", output);
	destroyWindow("absdiff");
	imshow("absdif", output);
	cvtColor(output, grey, CV_BGR2GRAY);
	cvtColor(actualShape->getShapeFrameMat(), preMask,CV_BGR2GRAY);

	threshold(preMask, mask, 0, 255, THRESH_BINARY);
	grey.copyTo(finalOutput,mask) ;
	
	int xPos = actualShape->getX() < 0 ? 0 : actualShape->getX();
	int yPos = actualShape->getY() < 0 ? 0 : actualShape->getY();
	int width = actualShape->getX() + actualShape->getWidth() < VideoWidth ? actualShape->getWidth() : VideoWidth - actualShape->getX();
	int height = actualShape->getY() + actualShape->getHeight() < VideoHeight ? actualShape->getHeight() : VideoWidth - actualShape->getY();
	if (width > 0 && height > 0) {
		return 1 - sum(finalOutput(Rect2d(xPos, yPos, width, height)))[0] / (sum(mask)[0]);
	}
	else {
		return 0;
	}
}
