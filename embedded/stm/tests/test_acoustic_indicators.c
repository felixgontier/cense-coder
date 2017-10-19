#include "audio_analyzer/acoustic_indicators.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/**
 * Read raw audio signal file
 */
int main(int argc, char **argv) {

  double RMS_REFERENCE_90DB = 2500;
  double DB_FS_REFERENCE = - (20 * log10(RMS_REFERENCE_90DB)) + 90;

	const char *filename = "speak_44100Hz_16bitsPCM_10s.raw";
	FILE *ptr;
	AcousticIndicatorsData acousticIndicatorsData;
    ai_NewAcousticIndicatorsData(&acousticIndicatorsData);

	int16_t shortBuffer[64];

	// open file
	ptr = fopen(filename, "rb");
	if (ptr == NULL) {
		printf("Error opening audio file\n");
		exit(1);
	}

	int read = 0;

	while(!feof(ptr)) {
		read = fread(shortBuffer, sizeof(int16_t), sizeof(shortBuffer) / sizeof(int16_t), ptr);
		// File fragment is in read array

		// Process short sample
		int sampleCursor = 0;
		do {
			int maxLen = ai_GetMaximalSampleSize(&acousticIndicatorsData);
			int sampleLen = read < maxLen ? read : maxLen;
			float leq;
			if(ai_AddSample(&acousticIndicatorsData, sampleLen, shortBuffer + sampleCursor, &leq,DB_FS_REFERENCE, false)) {

			}
			sampleCursor+=sampleLen;
		} while(sampleCursor < read);
	}

}
