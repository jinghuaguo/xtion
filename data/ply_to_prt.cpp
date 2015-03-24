#include <iostream>
#include <fstream>
#include <sstream>
#include <zlib.h>

#define CHUNK 100000

struct Header {
	char magicNumber[8];
	int length;
	char signature[32];
	int version;
	long long numberParticles;
};

struct Channel {
	int numberChannel;
	int lengthChannel;
	char channelName[32];
	int channelType;
	int channelArity;
	int channelOffset;
};

struct Particle {
	float x;
	float y;
	float z;
};

int getFramesNumber() {
	std::ifstream nbrFramesFile("nbr_frames.txt");
	int numberFrames;

	if (nbrFramesFile) {
		nbrFramesFile >> numberFrames;
		printf("%d frames\n", numberFrames);

		return numberFrames;
	}

	printf("No nbr_frames.txt file\n");

	return 1;
}

int getFirstFrameNumber(std::string param) {
	int firstFrame;

	std::istringstream(param) >> firstFrame;

	return firstFrame;
}

std::string getValidFileName( int nbr ) {
	std::stringstream plyFileName;
	std::string fileFrameName;
	plyFileName << "frame_" << nbr << ".ply";
	fileFrameName = plyFileName.str();

	return fileFrameName;
}

int getCurrentFrameNbrParticles(std::ifstream &plyFile) {
	std::string research_nbr;
	long long research_nbr_longlong;

	do {
		plyFile >> research_nbr;
	} while (research_nbr != "vertex");

	/* Here we get the number of particles */
	plyFile >> research_nbr;

	std::istringstream(research_nbr) >> research_nbr_longlong;
	printf("%llu particles\n", research_nbr_longlong);

	return research_nbr_longlong;
}

void moveToParticleData(std::ifstream &plyFile) {
	std::string research_nbr;

	do {
		plyFile >> research_nbr;
	} while (research_nbr != "end_header");
}

std::string getNewFileName(int nbr) {
	std::stringstream prtFileName;
	std::string fileFrameName;
	prtFileName << "dataCloud" << nbr << ".prt";
	fileFrameName = prtFileName.str();

	return fileFrameName;
}

int main(int argc, char ** argv) {
	int nbrFrames = getFramesNumber();
	int nbrFirst;

	if (argc > 1) {
		nbrFirst = getFirstFrameNumber(argv[1]);
		printf("Beginning at frame %d\n", nbrFirst);
	}
	else {
		nbrFirst = 0;
	}

	for (int i = 0; i < nbrFrames; i++) {
		std::string plyFileName = getValidFileName(nbrFirst + i);
		std::ifstream plyFile(plyFileName.c_str());

		if (!plyFile) {
			printf("%s not found !\n", plyFileName.c_str());
			return 2;
		}

		long long nbrParticles = getCurrentFrameNbrParticles(plyFile);

		moveToParticleData(plyFile);

		FILE *destFile;
		std::string newFileName = getNewFileName(nbrFirst + i);
		destFile = fopen(newFileName.c_str(), "wb");

		/*********************************************/

		/* Write header ******************************/

		Header h;
		memset(&h, 0, sizeof(Header));

		h.magicNumber[0] = 192;
		h.magicNumber[1] = 'P';
		h.magicNumber[2] = 'R';
		h.magicNumber[3] = 'T';
		h.magicNumber[4] = '\r';
		h.magicNumber[5] = '\n';
		h.magicNumber[6] = 26;
		h.magicNumber[7] = '\n';

		h.length = 56;
		strlcpy(h.signature, "Extensible Particle Format", 32);
		h.version = 1;
		h.numberParticles = nbrParticles;

		fwrite(&h, sizeof(Header), 1, destFile);

		int reserved = 4;

		fwrite(&reserved, sizeof(int), 1, destFile);

		/*********************************************/

		/* Write channel *****************************/

		Channel c;
		memset(&c, 0, sizeof(Channel));

		c.numberChannel = 1;
		c.lengthChannel = 44;
		strlcpy(c.channelName, "Position", 32);
		c.channelType = 4;
		c.channelArity = 3;
		c.channelOffset = 0;

		fwrite(&c, sizeof(Channel), 1, destFile);

		/*********************************************/

		/* Write compressed particle datas ***********/

		Bytef *dataOriginal	= (Bytef*)malloc(sizeof(Particle));
		Bytef *dataCompressed = (Bytef*)malloc(CHUNK);

		z_stream strm;
		strm.zalloc = Z_NULL;
		strm.zfree = Z_NULL;
		strm.opaque = Z_NULL;
		deflateInit(&strm, Z_DEFAULT_COMPRESSION);

		strm.avail_out = CHUNK;
		strm.next_out = dataCompressed;

		Particle p;
		float coord;
		int spaceUsed = 0;
		int flush;

		for (int j = 0; j < nbrParticles; j++) {
			memset(&p, 0, sizeof(Particle));

			plyFile >> coord;
			p.x = coord;
			plyFile >> coord;
			p.y = coord;
			plyFile >> coord;
			p.z = coord;

			memcpy(dataOriginal, &p, sizeof(Particle));

			strm.avail_in = sizeof(Particle);
			strm.next_in = dataOriginal;

			if (j == nbrParticles - 1) {
				flush = Z_FINISH;
			}
			else {
				flush = Z_NO_FLUSH;
			}

			int res = deflate(&strm, flush);

			if (res == Z_BUF_ERROR) {
				printf("BUFFER ERROR");
			}
			else if (res == Z_STREAM_ERROR) {
				printf("STREAM ERROR");
			}
			else if (res == Z_STREAM_END) {
				printf("END\n");
				spaceUsed = CHUNK - strm.avail_out;
			}
		}

		deflateEnd(&strm);

		fwrite(dataCompressed, spaceUsed, 1, destFile);

		fflush(destFile);
		fclose(destFile);

		free(dataOriginal);
		free(dataCompressed);
	}

	return 0;
}
