#pragma once
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

#define NUMBER_INIT_FRAMES 20

class VideoSegmenter
{
public:
	VideoSegmenter();
	~VideoSegmenter();
	TrackedObjects* update(Mat frame);
	Mat getBackground();
	double getFrameRate();
private:
	int currentObjectId;
	int frameNumber;
	int numObjects;
	int initFrameNumber; 
	TrackedObjects* trackedObjects;
	BackgroundExtractor* background;
	Mat outputFrame;
	double frameRate;
};