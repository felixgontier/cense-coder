#include "acoustic_indicators.h"


int ai_get_maximal_sample_size(const AcousticIndicatorsData* data) {
	return (sizeof(data->window_data) / sizeof(uint8_t)) - data->window_cursor;
}

bool ai_add_sample(AcousticIndicatorsData* data, int sample_len, const uint8_t sample_data[sample_len], float* laeq) {
	return false;
}

void newAcousticIndicatorsData(AcousticIndicatorsData* data)
{
	data->windows_count = 0;	
	data->window_cursor = 0;
}
