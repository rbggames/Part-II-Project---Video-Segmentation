#pragma once
#include <opencv2/opencv.hpp>
#include "Utilities.h"
using namespace cv;

class Shape
{
public:
	Shape();
	Shape(int x, int y, int width, int height, const Point** pts, const int* npt, Scalar colour=Scalar(255,0,255));
	Shape(int x, int y, int width, int height, const Point** pts, const int* npt, String texturePath);
	~Shape();
	Mat getMatrix();
	void updateDraw(Mat input);
	void setMotionVector(double mX, double mY);
	Mat getShapeFrameMat();
	virtual int getX();
	virtual int getY();
	int getWidth();
	int getHeight();
	Vec2d getMotionVector();
protected:
	int x, y, width, height;
	double motion_x, motion_y;
	Scalar colour;
	void initialise(int x, int y, int width, int height, const Point** pts, const int* npt,Scalar colour);
	void initialise(int x, int y, int width, int height, const Point** pts, const int* npt, String texturePath);
	Mat shapeMat, shapeFrameMat;//shapeMat is just the shape, shapeFrameMat is shape translated to its correct position in the frame
private:
	void draw(Mat input, int x, int y);
	int xOffset, yOffset;
};

