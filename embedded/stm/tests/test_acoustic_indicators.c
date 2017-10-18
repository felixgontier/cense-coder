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
    ai_NewAcousticIndicatorsData(&acousticIndicatorsData);

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
		// File fragment is in read array
		// Convert to uint8_t array
		uint8_t shortBuffer[64];
		for(int i=0; i < read / 2; i++) {
			shortBuffer[i] = (uint8_t) buffer[i*2];
		}
		
		// Process short sample
		int sampleCursor = 0;
		do {
			int maxLen = ai_GetMaximalSampleSize(&acousticIndicatorsData);
			printf("%d\n",maxLen);
			int sampleLen = read < maxLen ? read : maxLen;
			float leq;
			if(ai_AddSample(&acousticIndicatorsData, sampleLen, &shortBuffer[sampleCursor], &leq, false)) {				
				printf("Leq %d\n", leq);
			}
			sampleCursor+=sampleLen;
		} while(sampleCursor < read);
	}
	
}
