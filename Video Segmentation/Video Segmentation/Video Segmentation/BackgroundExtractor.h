#pragma once
#include <opencv2/opencv.hpp>
#include "TrackedObjects.h"

using namespace cv;

#define alpha 0.3

class BackgroundExtractor
{
public:
	Mat background;
	BackgroundExtractor(Mat frame,int initialisationFrames);
	~BackgroundExtractor();
	void update(Mat frame); 
	Mat getForground();
private:
	int thresh;
	int initialisationFrames;
	Mat previousFrame,mask,forground;
};

