#include "acoustic_indicators.h"
#include <stdio.h>
#include <inttypes.h>
#include <math.h>
#include <string.h>

int ai_GetMaximalSampleSize(const AcousticIndicatorsData* data) {
	return AI_WINDOW_SIZE - data->window_cursor;
}

bool ai_AddSample(AcousticIndicatorsData* data, int sample_len, const int16_t* sample_data, float* laeq, double ref_pressure, bool a_filter) {
	if(data->window_cursor + sample_len > AI_WINDOW_SIZE) {
		fprintf( stderr, "Exceed window array size (%d on %d)\n", "Out of bounds", data->window_cursor + sample_len, AI_WINDOW_SIZE);
		return false;
	}
	memcpy(data->window_data + data->window_cursor, sample_data, sample_len);
	data->window_cursor+=sample_len;
	int lenWindow = sizeof(data->window_data) / sizeof(int16_t);
	bool complete_window = data->window_cursor == lenWindow;
	if(data->window_cursor >= AI_WINDOW_SIZE) {
		data->window_cursor = 0;
		// Compute RMS
		double sampleSum = 0;
		for(int i=0; i < sample_len; i++) {
			sampleSum += sample_data[i] * sample_data[i];
		}
		sampleSum = sqrt(sampleSum);
		// Push L(A)eq of window into the data struct
	}
	return false;
}

void ai_NewAcousticIndicatorsData(AcousticIndicatorsData* data)
{
	data->windows_count = 0;
	data->window_cursor = 0;
}
