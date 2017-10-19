#include <inttypes.h>
#include <stdbool.h>

#ifndef ACOUSTIC_INDICATORS_H_
#define ACOUSTIC_INDICATORS_H_

// Note that only the sample rate 32khz is supported for (A) weigting.
#define AI_SAMPLING_RATE (32000)
#define AI_WINDOW_SIZE (1000)

typedef struct  {
	int window_cursor;
	int16_t window_data[AI_WINDOW_SIZE];
	int windows_count;
	float windows[AI_SAMPLING_RATE / AI_WINDOW_SIZE];
} AcousticIndicatorsData;

/**
 * Create new struct for acoustic indicators
 */
void ai_NewAcousticIndicatorsData(AcousticIndicatorsData* data);

/**
 * @param data instance of this struct, create an empty struct on first use
 */
int ai_GetMaximalSampleSize(const AcousticIndicatorsData* data);

/**
 * Add sample to the processing chain
 * @param[in,out] data instance of this struct, create an empty struct on first use
 * @param[in] sample_data sample content to add
 * @param[in] sample_len sample length of sample_data. Must be < than ai_get_maximal_sample_size
 * @param[out] laeq 1s laeq value if the return is true
 * @return True if a complete LAeq has been computed
 */
bool ai_AddSample(AcousticIndicatorsData* data, int sample_len, const int16_t* sample_data, float* laeq, double ref_pressure, bool a_filter);
#endif
