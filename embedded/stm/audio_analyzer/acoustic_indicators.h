#include <inttypes.h>
#include <stdbool.h>

#ifndef ACOUSTIC_INDICATORS_H_
#define ACOUSTIC_INDICATORS_H_

#define AI_SAMPLING_RATE (33000)
#define AI_WINDOW_SIZE (300)

typedef struct  {
	uint8_t window_data[AI_WINDOW_SIZE];
	int window_len;   //len in bytes of the buffer
	//float windowsLeq[(int)(AI_SAMPLING_RATE / )]
} AcousticIndicatorsData;

/**
 * @param data instance of this struct, create an empty struct on first use
 */
int ai_get_maximal_sample_size(const AcousticIndicatorsData* data);

/**
 * Add sample to the processing chain
 * @param[in,out] data instance of this struct, create an empty struct on first use
 * @param[in] sample_data sample content to add
 * @param[in] sample_len sample length of sample_data. Must be < than ai_get_maximal_sample_size
 * @param[out] laeq 1s laeq value if the return is true
 * @return True if a complete LAeq has been computed
 */
bool ai_add_sample(AcousticIndicatorsData* data, int sample_len, const uint8_t sample_data[sample_len], float* laeq);
#endif
