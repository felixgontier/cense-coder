#include "acoustic_indicators.h"
#include <stdio.h>
#include <inttypes.h>
#include <math.h>

int ai_GetMaximalSampleSize(const AcousticIndicatorsData* data) {
	return (sizeof(data->window_data) / sizeof(uint8_t)) - data->window_cursor;
}

bool ai_AddSample(AcousticIndicatorsData* data, int sample_len, const int16_t* sample_data, float* laeq, bool a_filter) {
	// Compute RMS
	double sampleSum = 0;
	for(int i=0; i < sample_len; i++) {
		sampleSum += sample_data[i] * sample_data[i];
	}
	sampleSum = sqrt(sampleSum);	
	return false;
}

void ai_NewAcousticIndicatorsData(AcousticIndicatorsData* data)
{
	data->windows_count = 0;	
	data->window_cursor = 0;
}
