import SimpleOpenNI.*;

int minZ = 0;
int maxZ = 1500;
int steps = 4;
float rotX = radians(180);
float rotY = 0;
float zoom = 0.3f;

SimpleOpenNI context;

void setup() {
	size(1024, 768, P3D);

	context = new SimpleOpenNI(this, "record.oni");

	stroke(255, 255, 255);
	perspective(radians(45), float(width) / float(height), 10, 150000);
}

void draw() {
	context.update();
	background(0, 0, 0);

	translate(width / 2, height / 2, 0);
	rotateX(rotX);
	rotateY(rotY);
	scale(zoom);
	translate(0, 0, -1000);

	int[] depthMap = context.depthMap();
	int depthWidth = context.depthWidth();
	int depthHeight = context.depthHeight();
	PVector[] realWorldMap = context.depthMapRealWorld();

	beginShape(POINTS);

	for (int i = 0; i < depthHeight; i += steps) {

		for (int j = 0; j < depthWidth; j += steps) {

			int index = j + i * context.depthWidth();

			if (depthMap[index] > 0) {

				PVector realWorldPoint = realWorldMap[index];

				if (realWorldPoint.z > minZ && realWorldPoint.z < maxZ) {
					vertex(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
				}
			}
		}
	}

	endShape();

	context.drawCamFrustum();
}

void keyPressed() {
	if (key == 'a') {
		maxZ -= 100;
		println("maxZ " + maxZ);
	}
	else if (key == 'z') {
		maxZ += 100;
		println("maxZ " + maxZ);
	}
	else if (key == 'q') {
		minZ -= 100;
		println("minZ " + minZ);
	}
	else if (key == 's') {
		minZ += 100;
		println("minZ " + minZ);
	}
	else if (key == 'o') {
		steps++;
		println("STEPS " + steps);
	}
	else if (key == 'p') {
		if (steps - 1 > 0) {
			steps--;
		}
		println("STEPS " + steps);
	}
	else {
		switch (keyCode) {
			case LEFT:
			rotY += 0.1f;
			break;

			case RIGHT:
			rotY -= 0.1f;
			break;

			case UP:
			rotX -= 0.1f;
			break;

			case DOWN:
			rotX += 0.1f;
			break;
		}
	}
}
