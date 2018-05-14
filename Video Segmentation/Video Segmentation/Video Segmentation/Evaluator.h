#pragma once
#include "Shape.h"
#include "TrackedObject.h"
#include "TrackedObjects.h"
#include "VideoSource.h"
#include <iostream>
#include <fstream>

class Evaluator
{
public:
	Evaluator();
	~Evaluator();

	static void evaluateSegments(Shape ** actualShapes, int numShapes, TrackedObjects trackedShapes,int runId,int frameNum,Mat bg,VideoSource vs,double frameRate,String outputFolder);

	static double evaluateSegmentsSimalarity(Shape* actualShape, TrackedObject* object);
	static double evaluateSegmentsSimalarity(Mat actualShape, Mat object,Rect2d roi);
};

