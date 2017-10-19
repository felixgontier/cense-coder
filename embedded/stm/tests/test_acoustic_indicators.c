#include "audio_analyzer/acoustic_indicators.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "minunit.h"

int tests_run = 0;

/**
 * Read raw audio signal file
 */
static char * test_leq_32khz() {
  // Compute the reference level.
  //double RMS_REFERENCE_90DB = 2500;
  //double DB_FS_REFERENCE = - (20 * log10(RMS_REFERENCE_90DB)) + 90;
  //double REF_SOUND_PRESSURE = 1 / pow(10, DB_FS_REFERENCE / 20);

  double REF_SOUND_PRESSURE = 32767.;

	const char *filename = "speak_32000Hz_16bitsPCM_10s.raw";
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

  int total_read = 0;
	int read = 0;
  float leqs[10];
  int leqId = 0;

	while(!feof(ptr)) {
		read = fread(shortBuffer, sizeof(int16_t), sizeof(shortBuffer) / sizeof(int16_t), ptr);
    total_read+=read;
		// File fragment is in read array
		// Process short sample
		int sampleCursor = 0;
		do {
			int maxLen = ai_GetMaximalSampleSize(&acousticIndicatorsData);
			int sampleLen = (read - sampleCursor) < maxLen ? (read - sampleCursor) : maxLen;
			float leq;
			if(ai_AddSample(&acousticIndicatorsData, sampleLen, shortBuffer + sampleCursor, &leq,REF_SOUND_PRESSURE, false)) {
        mu_assert("Too much iteration", leqId < 10);
        leqs[leqId++] = leq;
			}
			sampleCursor+=sampleLen;
		} while(sampleCursor < read);
	}
  return 0;
}

static char * all_tests() {
   mu_run_test(test_leq_32khz);
   return 0;
}

int main(int argc, char **argv) {
     char *result = all_tests();
     if (result != 0) {
         printf("%s\n", result);
     }
     else {
         printf("ALL TESTS PASSED\n");
     }
     printf("Tests run: %d\n", tests_run);

     return result != 0;
}
