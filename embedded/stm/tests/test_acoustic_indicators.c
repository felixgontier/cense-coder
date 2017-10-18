#include "audio_analyzer/acoustic_indicators.h"
#include <stdio.h>
#include <stdlib.h>

/**
 * Read raw audio signal file
 */
int main(int argc, char **argv) {
	char *filename;
	filename = (char*) malloc(sizeof(char) * 1024);
	if (filename == NULL) {
		printf("Error in malloc\n");
		exit(1);		
	}
}
