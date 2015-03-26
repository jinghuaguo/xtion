import SimpleOpenNI.*;

int minZ = 0;
int maxZ = 1500;
int steps = 4;
int frames;

SimpleOpenNI context;

void setup() {
	size(1024, 768, P3D);

	context = new SimpleOpenNI(this, "record.oni");

	frames = int(loadStrings(dataPath("nbr_frames.txt"))[0]);
}

void draw() {
	noLoop();

	int depthWidth = context.depthWidth();
	int depthHeight = context.depthHeight();

	for(int i = 0; i < frames; i++) {

		PrintWriter output = createWriter(dataPath("frame_" + i + ".ply"));
		output.println("ply");
		output.println("format ascii 1.0");
		output.println("comment made by @arthurmuchir");

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

		println("saved " + (i + 1) + " of " + frames);

		context.update();
	}

	println("recorded " + frames + " frames");
	exit();
}
