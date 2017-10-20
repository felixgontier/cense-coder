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
	memcpy(data->window_data + data->window_cursor, sample_data, sample_len * sizeof(int16_t));
	data->window_cursor+=sample_len;
	if(data->window_cursor >= AI_WINDOW_SIZE) {
		data->window_cursor = 0;
		// Compute RMS
		long sampleSum = 0;
		for(int i=0; i < AI_WINDOW_SIZE; i++) {
			sampleSum += (long)data->window_data[i] * (long)data->window_data[i];
		}
		// Push window sum in windows struct data
		data->windows[data->windows_count++] = sampleSum;
		if(data->windows_count == AI_WINDOWS_SIZE) {
				// compute energetic average
				long sumWindows = 0;
				for(int i=0; i<AI_WINDOWS_SIZE;i++) {
					sumWindows+=data->windows[i];
				}
				// Convert into dB(A)
				*laeq = 20 * log10(sqrt((double)sumWindows / (AI_WINDOWS_SIZE * AI_WINDOW_SIZE)) / ref_pressure);
				data->windows_count = 0;
				return true;
		}
	}
	return false;
}

void ai_NewAcousticIndicatorsData(AcousticIndicatorsData* data)
{
	data->windows_count = 0;
	data->window_cursor = 0;
	memset(data->window_data, 0 , sizeof(int16_t) * AI_WINDOW_SIZE);
}
