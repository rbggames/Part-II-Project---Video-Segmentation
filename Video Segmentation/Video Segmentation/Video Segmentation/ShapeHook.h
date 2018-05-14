#pragma once
#include "Shape.h"
#include "Utilities.h"

class ShapeHook : public Shape
{
public:
	ShapeHook(int x, int y,int width,Scalar colour=Scalar(255,0,0));
	ShapeHook(int x, int y, int width, String texturePath);
	~ShapeHook();

	virtual int getX();
	virtual int getY();
private:
	Point hook_points[1][7];
	int xOffset, yOffset;
};

