#include "stdafx.h"
#include <opencv2/opencv.hpp>
#include <opencv2/tracking.hpp>
#include <opencv2/core/ocl.hpp>
#include "Shape.h"
#include "ShapeHook.h"
#include "TrackedObject.h"
#include "TrackedObjects.h"
#include "VideoSource.h"
#include "BackgroundExtractor.h"
#include "Evaluator.h"
#include <math.h>

#include "Utilities.h"
#include "VideoSegmenter.h"

using namespace cv;
using namespace std;


const int maxObjects = 10;
#define ACCEPTANCE_PROBABILITY 0.9
RNG rng(12345);
int currentObjectId = 0;

int main(int argc, char **argv)
{
	VideoSource video;
	//video.newRestrictedCollideScene();
	//video.newRestrictedCollideScene();
	//video.newRestrictedCollideScene();
	//video.newRestrictedCollideScene();

	Mat frame(600, 600, CV_8UC3), outputFrame;
	VideoCapture vid("videos\\test.mp4");


	VideoSegmenter videoSegmenter;
	TrackedObjects* trackedObjects;

	for (int i = 0; i < 0; i++) {
		VideoSegmenter videoSegmenter;
		TrackedObjects* trackedObjects;

		video.newRestrictedCollideScene();
		for (int timer = 0; timer < 200; timer++) {

			video.getFrame(frame);
			trackedObjects = videoSegmenter.update(frame);

			//Evaluation
			int numShapes;
			Shape** shapes = video.getShapes(&numShapes);
			double frameRate = videoSegmenter.getFrameRate();
			String outputFolder = "Evaluation//Collides";
			Evaluator::evaluateSegments(shapes, numShapes, *trackedObjects, i, timer, videoSegmenter.getBackground(), video, frameRate, outputFolder);
		}
	}

	for (int i = 0; i < 100; i++) {
		VideoSegmenter videoSegmenter;
		TrackedObjects* trackedObjects;
		if (i > -1) {
			for (int timer = 0; timer < 300; timer++) {

				video.getFrame(frame);
				trackedObjects = videoSegmenter.update(frame);

				//Evaluation
				int numShapes;
				Shape** shapes = video.getShapes(&numShapes);
				double frameRate = videoSegmenter.getFrameRate();
				String outputFolder = "Evaluation//NoCollide";
				Evaluator::evaluateSegments(shapes, numShapes, *trackedObjects, i, timer, videoSegmenter.getBackground(), video, frameRate, outputFolder);
			}
		}
		video.newScene(3);
	}


	video.newRestrictedCollideScene();
	for (int timer = 0; timer < 600; timer++) {

		vid.read(outputFrame);
		resize(outputFrame, frame, frame.size());
		GaussianBlur(frame, frame, Size(9, 9), 1, 1);
		trackedObjects = videoSegmenter.update(frame);
	}

	return 0;
	
}