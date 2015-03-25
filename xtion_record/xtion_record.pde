import SimpleOpenNI.*;

boolean IS_RECORDING_MOD = false;

int minZ = 0;
int maxZ = 1500;
int steps = 4;
int frames;
float rotX = radians(180);
float rotY = 0;
float zoom = 0.3f;

SimpleOpenNI context;

void setup() {
	size(1024, 768, P3D);

	if (!IS_RECORDING_MOD) {
		context = new SimpleOpenNI(this, "record.oni");
	}
	else {
		context = new SimpleOpenNI(this);

		if (!context.isInit()) {
			println("Cannot init camera, maybe not connected");
			exit();
		}

		context.setMirror(true);
		context.enableDepth();
		context.enableRecorder("record.oni");
		context.addNodeToRecording(SimpleOpenNI.NODE_DEPTH, true);
	}

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
	int index;
	PVector[] realWorldMap = context.depthMapRealWorld();
	PVector realWorldPoint;

	beginShape(POINTS);

	for (int i = 0; i < depthHeight; i += steps) {

		for (int j = 0; j < depthWidth; j += steps) {

			index = j + i * context.depthWidth();

			if (depthMap[index] > 0) {

				realWorldPoint = realWorldMap[index];

				if (realWorldPoint.z > minZ && realWorldPoint.z < maxZ) {
					vertex(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
				}
			}
		}
	}

	endShape();

	context.drawCamFrustum();

	if (IS_RECORDING_MOD) {
		frames++;
	}
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
	else if ( key == ' ' ) {
		if (IS_RECORDING_MOD) {

			// Convert frames to string and cut the string space
			saveStrings(dataPath("nbr_frames.txt"), split(frames + " ", " "));
			println("Record " + frames + " frames");
			exit();
		}
		else {
			noLoop();

			saveOniToPly();
			exit();
		}
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

void saveOniToPly() {
	frames = int(loadStrings(dataPath("nbr_frames.txt"))[0]);
	int depthWidth = context.depthWidth();
	int depthHeight = context.depthHeight();

	for(int i = 0; i < frames; i++) {

		PrintWriter output = createWriter(dataPath("frame_" + i + ".ply"));
		output.println("ply");
		output.println("format ascii 1.0");
		output.println("comment made by @arthurmuchir");

		int[] depthMap = context.depthMap();
		int nbr_vertex = 0;
		int index;
		PVector[] realWorldMap = context.depthMapRealWorld();
		PVector realWorldPoint;
		String coord = "";

		for (int j = 0; j < depthHeight; j += steps) {

			for (int k = 0; k < depthWidth; k += steps) {

				index = j * depthWidth + k;

				if (depthMap[index] > 0) {
					realWorldPoint = realWorldMap[index];

					if (realWorldPoint.z > minZ && realWorldPoint.z < maxZ) {
						nbr_vertex++;
						coord += realWorldPoint.x + " " + realWorldPoint.y + " " + realWorldPoint.z + "\n";
					}
				}
			}
		}

		output.println("element vertex " + nbr_vertex);
		output.println("property float x");
		output.println("property float y");
		output.println("property float z");
		output.println("end_header");
		output.println(coord);

		output.flush();
		output.close();
		context.update();
		nbr_vertex = 0;

		println("saved " + (i + 1) + " of " + frames);
	}

	println("recorded " + frames + " frames");
}
