#include "stdafx.h"
#include "VideoSource.h"

#include "ShapeHook.h"
#include "ShapeSquare.h"


VideoSource::VideoSource()
{
	int w = 60;
	shapes[0] = new ShapeHook(000, 300, w,"Images\\bright.jpg");
	shapes[0]->setMotionVector(1.0, 0.0);
	shapes[1] = new ShapeHook(400, 330, w, "Images\\wood.jpg");
	shapes[1]->setMotionVector(-1.0, 0.0);

	shapes[2] = new ShapeSquare(400, 300, w, "Images\\lava.jpg");
	shapes[2]->setMotionVector(1.0, 1.0);
	//shapes[3] = new ShapeHook(400, 530, w, Scalar(0, 255, 0));
	//shapes[3]->setMotionVector(-1.0, 0.0);

	//shapes[4] = new ShapeHook(200, 20, w);
	//shapes[4]->setMotionVector(1.0, 0.0);
	//shapes[5] = new ShapeHook(400, 30, w, Scalar(0, 255, 0));
	//shapes[5]->setMotionVector(-1.0, 0.0);

	numShapes = 3;
	width = 600;
	height = 600;
}


VideoSource::~VideoSource()
{
}

bool VideoSource::getFrame(Mat frame)
{
	Mat backgroundImg;
	backgroundImg = imread("Images\\background.jpg");
	backgroundImg(Rect2d(0,0, frame.cols, frame.rows)).copyTo(frame);
	//frame.setTo(Scalar(0, 0, 0));
	for (int i = 0; i < numShapes; i++)
		shapes[i]->updateDraw(frame);
	return true;
}

Shape** VideoSource::getShapes(int * numberShapes)
{
	*numberShapes = numShapes;
	return shapes;
}

void VideoSource::newScene(int numObjects)
{
	numShapes = numObjects;
	for (int i = 0; i < numObjects; i++) {
		//Max num objects is 10
		if (i < 10) {
			auto randType = rng.uniform(0.0, 1.0);
			auto randX = rng.uniform(0, 600);
			auto randY = rng.uniform(0, 600);
			auto randWidth = rng.uniform(40, 100);
			int randBackground = rng.uniform(0, 3);
			auto randMotionX = rng.uniform(-4, 4);
			auto randMotionY = rng.uniform(-4, 4);

			String backgroundPath;
			switch (randBackground)
			{
			case 0:
				backgroundPath = "Images\\wall.jpg";
				break;
			case 1:
				backgroundPath = "Images\\lava.jpg";
				break;
			default:
				backgroundPath = "Images\\wood.jpg";
				break;
			}

			if (randType < 0.5) {
				shapes[i] = new ShapeHook(randX, randY, randWidth, backgroundPath);
			}
			else {
				shapes[i] = new ShapeSquare(randX, randY, randWidth, backgroundPath);
			}
			shapes[i]->setMotionVector(randMotionX, randMotionY);
		}
	}
}

void VideoSource::newCollideScene()
{
	int obj1VelocityX = 0;
	int obj2VelocityX = 0;
	int obj1VelocityY = 0;
	int obj2VelocityY = 0;
	int obj1CentreX = 0;
	int obj2CentreX = 600;
	int obj1CentreY = 0;
	int obj2CentreY = 600;

	int collideFrameNum = 100;

	numShapes = 2;
	int x = (((obj1CentreX + obj1VelocityX * collideFrameNum) - (obj2CentreX + obj2VelocityX * collideFrameNum)));
	int y = (((obj1CentreY + obj1VelocityY * collideFrameNum) - (obj2CentreY + obj2VelocityY * collideFrameNum)));
	//Make sure do collide
	while (x*x > 30 || y*y > 30) {
		for (int i = 0; i < numShapes; i++) {
			//Max num objects is 5
			if (i < 5) {
				auto randType = rng.uniform(0.0, 1.0);
				auto randX = rng.uniform(0, 300);
				randX += 300 * i;
				auto randY = rng.uniform(0, 300);
				randY += 300 * i;
				auto randWidth = rng.uniform(40, 100);
				int randBackground = rng.uniform(0, 3);

				String backgroundPath;
				switch (randBackground)
				{
				case 0:
					backgroundPath = "Images\\wall.jpg";
					break;
				case 1:
					backgroundPath = "Images\\lava.jpg";
					break;
				default:
					backgroundPath = "Images\\wood.jpg";
					break;
				}

				if (randType < 0.5) {
					shapes[i] = new ShapeHook(randX, randY, randWidth, backgroundPath);
				}
				else {
					shapes[i] = new ShapeSquare(randX, randY, randWidth, backgroundPath);
				}
			}
		}
		int randCollisionPointX = rng.uniform(100, 500);
		int randCollisionPointY = rng.uniform(100, 500);

		obj1CentreX = shapes[0]->getWidth() / 2 + shapes[0]->getX();
		obj2CentreX = shapes[1]->getWidth() / 2 + shapes[1]->getX();
		obj1CentreY = shapes[0]->getHeight() / 2 + shapes[0]->getY();
		obj2CentreY = shapes[1]->getHeight() / 2 + shapes[1]->getY();


		obj1VelocityX = (randCollisionPointX - obj1CentreX) / collideFrameNum;
		obj2VelocityX = (randCollisionPointX - obj2CentreX) / collideFrameNum;
		obj1VelocityY = (randCollisionPointY - obj1CentreY) / collideFrameNum;
		obj2VelocityY = (randCollisionPointY - obj2CentreY) / collideFrameNum;

		x = (((obj1CentreX + obj1VelocityX * collideFrameNum) - (obj2CentreX + obj2VelocityX * collideFrameNum)));
		y = (((obj1CentreY + obj1VelocityY * collideFrameNum) - (obj2CentreY + obj2VelocityY * collideFrameNum)));
	}
	shapes[0]->setMotionVector(obj1VelocityX, obj1VelocityY);
	shapes[1]->setMotionVector(obj2VelocityX, obj2VelocityY);

}

void VideoSource::newRestrictedCollideScene() {
	numShapes = 2;
	int randCollisionPointX = rng.uniform(300, 350);
	int randCollisionPointY = rng.uniform(300, 350);

	int objVelX[2], objVelY[2];

	int collisionTime = 120;
	objVelX[0] = 0; objVelY[0] = 0;
	while (objVelX[0] == 0 && objVelY[0] == 0) {
		objVelX[0] = rng.uniform(0, 4);
		objVelY[0] = rng.uniform(-4, 4);
	}

	objVelX[1] = 0; objVelY[1] = 0;
	while (objVelX[1] == 0 && objVelY[1] == 0) {
		objVelX[1] = rng.uniform(-4, 0);
		objVelY[1] = rng.uniform(-4, 4);
	}


	int randBackground = rng.uniform(0, 3);
	for (int i = 0; i < 2; i++) {
			auto randType = rng.uniform(0.0, 1.0);
			auto randWidth = rng.uniform(50, 80);
			auto randX = randCollisionPointX - collisionTime*objVelX[i];
			auto randY = randCollisionPointY - collisionTime*objVelY[i];

			String backgroundPath;
			randBackground = (randBackground + 1) % 3;
			switch (randBackground)
			{
			case 0:
				backgroundPath = "Images\\wall.jpg";
				break;
			case 1:
				backgroundPath = "Images\\lava.jpg";
				break;
			default:
				backgroundPath = "Images\\wood.jpg";
				break;
			}

			if (randType < 0.5) {
				shapes[i] = new ShapeHook(randX, randY, randWidth, backgroundPath);
			}
			else {
				shapes[i] = new ShapeSquare(randX, randY, randWidth, backgroundPath);
			}
			shapes[i]->setMotionVector(objVelX[i], objVelY[i]);
	}

}

Mat VideoSource::getBackground()
{
	Mat backgroundImg;
	backgroundImg = imread("Images\\background.jpg");
	return backgroundImg(Rect2d(0, 0, width,height));
}


