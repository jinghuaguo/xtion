import SimpleOpenNI.*;

int minZ = 0;
int maxZ = 1500;
int steps = 4;
int currentFrame = 0;
int frames;

SimpleOpenNI context;

void setup() {
	size(1024, 768, P3D);

	context = new SimpleOpenNI(this);
	context.openFileRecording("record.oni");

	frames = int(loadStrings(dataPath("nbr_frames.txt"))[0]);
}

void draw() {

	PrintWriter output = createWriter(dataPath("frame_" + currentFrame + ".ply"));
	output.println("ply");
	output.println("format ascii 1.0");
	output.println("comment made by @arthurmuchir");

	int depthWidth = context.depthWidth();
	int depthHeight = context.depthHeight();
	int[] depthMap = context.depthMap();
	int nbr_vertex = 0;
	PVector[] realWorldMap = context.depthMapRealWorld();
	String coord = "";

	for (int j = 0; j < depthHeight; j += steps) {

		for (int k = 0; k < depthWidth; k += steps) {

			int index = j * depthWidth + k;

			if (depthMap[index] > 0) {
				PVector realWorldPoint = realWorldMap[index];

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

	println("saved " + (currentFrame + 1) + " of " + frames);

	context.update();

	if (currentFrame < frames) {
		currentFrame++;
	}
	else {
		println("recorded " + frames + " frames");
		exit();
	}
}
