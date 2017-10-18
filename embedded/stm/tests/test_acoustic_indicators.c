#include "audio_analyzer/acoustic_indicators.h"
#include <stdio.h>
#include <stdlib.h>

/**
 * Read raw audio signal file
 */
int main(int argc, char **argv) {
	const char *filename = "speak_32000Hz_16bitsPCM_10s.raw";
	FILE *ptr;
	AcousticIndicatorsData acousticIndicatorsData;
    newAcousticIndicatorsData(&acousticIndicatorsData);

	unsigned char buffer[128];

	// open file
	ptr = fopen(filename, "rb");
	if (ptr == NULL) {
		printf("Error opening audio file\n");
		exit(1);
	}

	int read = 0;

	while(!feof(ptr)) {
		read = fread(buffer, sizeof(buffer), 1, ptr);
		int maxLen = ai_get_maximal_sample_size(&acousticIndicatorsData);
	}
	
}
