#include "audio_analyzer/acoustic_indicators.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "minunit.h"

int tests_run = 0;
//char *message = (char*)malloc(256 * sizeof(char));
char mu_message[256];

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
  float expected_leqs[10] = {-28.24,-25.99,-28.70,-30.62,-33.09,-25.00,-31.12,-30.62,-29.22,-31.81};

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
        mu_assert("Too much iteration, more than 10s in file or wrong sampling rate", leqId < 10);
        leqs[leqId++] = leq;
			}
			sampleCursor+=sampleLen;
		} while(sampleCursor < read);
	}
  mu_assert("Wrong number of parsed samples", total_read == 320000);

  // Check expected leq

  for(int second = 0; second < 10; second++) {
    sprintf(mu_message, "Wrong leq on %i second expected %f dB got %f dB", second, expected_leqs[second], leqs[second]);
    mu_assert(mu_message, abs(expected_leqs[second] - leqs[second]) < 0.01);
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
