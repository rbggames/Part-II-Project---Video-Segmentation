// Video Segmentation.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "VideoSegmenter.h"

using namespace std;

VideoSegmenter::VideoSegmenter()
{
	ocl::setUseOpenCL(true);
	RNG rng(12345);

	// Read first frame
	Mat frame(600, 600, CV_8UC3), outputFrame;

	VideoSource video;
	video.getFrame(frame);

	int numObjects = 0;
	int num = 0;

	trackedObjects = new TrackedObjects(frame);

	background = new BackgroundExtractor(frame, 10);
}

VideoSegmenter::~VideoSegmenter()
{
	free(trackedObjects);
	free(background);
}

TrackedObjects* VideoSegmenter::update(Mat frame)
{
	imshow("Tracking", frame);
	if(initFrameNumber < NUMBER_INIT_FRAMES){
		//video.getFrame(frame);
		background->update(frame);
		initFrameNumber++;
	}else{
	Mat prevFrame;
	frame.copyTo(prevFrame);
		//Utilities::get_object_contours(frame, prevFrame, 1000);

		frame.copyTo(prevFrame);
		imshow("framea", frame);
		imshow("frameb", prevFrame);

		// Start timer
		double timer = (double)getTickCount();
		Mat forground = background->getForground();

		if (frameNumber % 30 == 2) {
			numObjects = trackedObjects->consolidateObjects();
		}

		if (frameNumber % 3 == 0) {
			numObjects = trackedObjects->find(forground);
		}
		frame.copyTo(outputFrame);

		//TODO: Could be got from elsewhere
		//Mat cannyFrame;
		//Canny(frame, cannyFrame, 30, 200);

		numObjects = trackedObjects->update(forground, outputFrame);
		//background.update(frame,trackedObjects,numObjects);
		background->update(frame);

		frameNumber++;
		//background.update(frame);

		// Calculate Frames per second (FPS)
		float fps = getTickFrequency() / ((double)getTickCount() - timer);
		frameRate = fps;

		// Display FPS on frame
		putText(frame, "FPS : " + SSTR(int(fps)), Point(100, 50), FONT_HERSHEY_SIMPLEX, 0.75, Scalar(50, 170, 50), 2);

		// Display frame.
		imshow("Tracking", frame);

		
		int key = waitKey(1);

		//Pause
		if (key == 'p') {
			key = 0;
			while (key != 'p') {
				key = waitKey(5);
				//Cycle Through Tracked Objects
				if (key == 'n') {
					currentObjectId = (currentObjectId + 1) % (numObjects > 0 ? numObjects : 1);
				}
				TrackedObject* curObject = trackedObjects->getTrackedObject(currentObjectId);
				if (curObject) {
					Mat obj;
					curObject->getObjectMat().copyTo(obj);
					rectangle(obj, curObject->getTrackerBoundingBox(), Scalar(0, 0, 0));
					rectangle(obj, curObject->getBoundingBox(), Scalar(255, 0, 0));
					putText(obj, "Tracked (" + SSTR(currentObjectId) + ") :" + SSTR(curObject->getId()) + " Angle: " + SSTR(curObject->getMotionAngle()), Point(10, 20), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200, 200, 250), 1, CV_AA);
					imshow("Object", obj);
				}
			}
		}
		//Cycle Through Tracked Objects
		if (key == 'n') {
			currentObjectId = (currentObjectId + 1) % (numObjects > 0 ? numObjects : 1);
		}
		TrackedObject* curObject = trackedObjects->getTrackedObject(currentObjectId);
		if (curObject) {
			Mat obj;
			curObject->getObjectMat().copyTo(obj);
			rectangle(obj, curObject->getTrackerBoundingBox(), Scalar(0, 0, 0));
			rectangle(obj, curObject->getBoundingBox(), Scalar(255, 0, 0));
			putText(obj, "Tracked (" + SSTR(currentObjectId) + ") :" + SSTR(curObject->getId()) + " Angle: " + SSTR(curObject->getMotionAngle()), Point(10, 20), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200, 200, 250), 1, CV_AA);
			imshow("Object", obj);
		}

	}
	return trackedObjects;
}

Mat VideoSegmenter::getBackground()
{
	return background->background;
}

double VideoSegmenter::getFrameRate()
{
	return frameRate;
}
