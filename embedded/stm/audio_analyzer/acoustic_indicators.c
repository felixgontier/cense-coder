#include "acoustic_indicators.h"


int ai_GetMaximalSampleSize(const AcousticIndicatorsData* data) {
	return (sizeof(data->window_data) / sizeof(uint8_t)) - data->window_cursor;
}

bool ai_AddSample(AcousticIndicatorsData* data, int sample_len, const uint8_t* sample_data, float* laeq, bool a_filter) {
	return false;
}

void ai_NewAcousticIndicatorsData(AcousticIndicatorsData* data)
{
	data->windows_count = 0;	
	data->window_cursor = 0;
}
