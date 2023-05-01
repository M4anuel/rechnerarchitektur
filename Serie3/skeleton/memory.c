/*
 * author:   Manuel Flückiger
 * modified:    2023-04-17
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "memory.h"

MemoryRegion * memoryRegions[MEMORY_REGION_SIZE];
FILE * outputStream;

void emptyMemoryRegionInitializer() {}

/* ========================================================================== */
/* DEFAULT MEMORY */
byte defaultMemoryData[RAM_SIZE];

void defaultMemoryInitializer() {
	int i;
	for (i=0; i<RAM_SIZE; ++i) {
		defaultMemoryData[i] = 0;
	}
}

void defaultMemoryWriteHandler(word address, byte value) {
	defaultMemoryData[address] = value;
}

byte defaultMemoryReadHandler(word address) {
	return defaultMemoryData[address];
}

MemoryRegion defaultMemory = {
    0, 
    RAM_SIZE-1, 
    &defaultMemoryInitializer,
    &defaultMemoryWriteHandler, 
    &defaultMemoryReadHandler
};

/* NEW Macro */

/* ========================================================================== */
/* printf memory */
void fprintfMemoryRegionInitializer() {
	outputStream = stdout;
}

void fprintfMemoryWriteHandler(word address, byte value) {
        fprintf(outputStream, "%c", value);
}

byte fprintfMemoryReadHandler(word address) {
        /* ignore reads, only used to output */
	return 0;
}

MemoryRegion fprintfMemory = {
    FPRINTF_MEMORY_LOCATION, 
    FPRINTF_MEMORY_LOCATION, 
    &fprintfMemoryRegionInitializer,
    &fprintfMemoryWriteHandler, 
    &fprintfMemoryReadHandler
};

/* ========================================================================== */
/* time memory */

void timeMemorWriteHandler(word address, byte value) {}

byte timeMemoryReadHandler(word address) {
	return clock() * 1000 / CLOCKS_PER_SEC;
}

MemoryRegion timeMemory = {
    TIME_MEMORY_LOCATION, 
    TIME_MEMORY_LOCATION, 
    &emptyMemoryRegionInitializer,
    &timeMemorWriteHandler, 
    &timeMemoryReadHandler
};

/* ========================================================================== */

int checkMemoryRegionOverlap(MemoryRegion *region) {
   	int i;
	for (i=0; i<MEMORY_REGION_SIZE; ++i) {
        if (!memoryRegions[i]) {
            break;
        }
		if (((memoryRegions[i]->min >= region->min) && ( region->min <= memoryRegions[i]->max))
            || ((memoryRegions[i]->min >= region->max) && (region->max <= memoryRegions[i]->max))) {
			return FALSE;
		}
	}
    return TRUE;
}

int memoryRegionCounter = 0;

void registerMemoryRegion(MemoryRegion *region) {
    if (checkMemoryRegionOverlap(region)) {
        memoryRegions[memoryRegionCounter] = region;
        memoryRegionCounter++;
        region->initialize();
    } else {
        ERROR("Overlapping memory regions");
    }
}

void initializeMemory() {
    int i;
    memoryRegionCounter = 0;
    for (i=0; i<MEMORY_REGION_SIZE; ++i) {
        memoryRegions[i] = NULL;
    }
    registerMemoryRegion(&defaultMemory);
    registerMemoryRegion(&fprintfMemory);
    registerMemoryRegion(&timeMemory);
}

/* MEMORY FUNCTIONS ========================================================= */
word decode(unsigned char buffer[4]);
long get_file_size(char *);

/* Load a file to memory */
void loadFile(char* filename) {
    FILE *fptr;

     if(fptr == NULL) {
        perror("Error: Cant open file");
    }
    unsigned char buffer[4];//32bit string
    fptr = fopen(filename, "rb"); // r for read, b for binary
    word location = 0;
    for (int i = 0; i < get_file_size(filename); i++){
        fseek(fptr, sizeof(buffer)*i, SEEK_SET);
        fread(buffer, sizeof(buffer), 1, fptr);
        
        storeWord(decode(buffer),location);
        location += 4;
    }
    fclose(fptr);
}
/*decodes lines from big endian */
word decode(unsigned char buffer[4]) {
    word w = 0;
    int i;
    for (i = 0; i < 4; i++) {
        w = (w << 8) | (buffer[i] & 0xFF);
    }
    return w;
}
/*gets amount of commands in our programme*/
long get_file_size(char *filename) {
    FILE *fp = fopen(filename, "r");

    if (fp==NULL)
        return -1;

    if (fseek(fp, 0, SEEK_END) < 0) {
        fclose(fp);
        return -1;
    }

    long size = ftell(fp);
    // release the resources when not required
    fclose(fp);
    return size/4;//divided by 4 to fit our command length
}
/* ========================================================================== */

MemoryRegion* getMemoryRegion(word location) {
    int i;
    MemoryRegion *memoryRegion = NULL;
    for (i=0; i<MEMORY_REGION_SIZE && !memoryRegion; ++i) {
        if (memoryRegions[i] && memoryRegions[i]->min <= location && memoryRegions[i]->max >= location) {
	    memoryRegion = memoryRegions[i];
	}
    }
    if (!memoryRegion) {
        ERROR("Invalid memory access at 0x%x", (int) location);
    }
    return memoryRegion;
}


/* Store a word to memory */
void storeWord(word w, word location) {
	MemoryRegion *memoryRegion = getMemoryRegion(location);
	memoryRegion->write(location,   (w >> (8*3)) & 0xFF);
	memoryRegion->write(location+1, (w >> (8*2)) & 0xFF);
	memoryRegion->write(location+2, (w >> (8*1)) & 0xFF);
	memoryRegion->write(location+3, (w >> (8*0)) & 0xFF);
}

/* Load a word from memory */
word loadWord(word location) {
	MemoryRegion *memoryRegion = getMemoryRegion(location);
	word w = 0;
	w += (memoryRegion->read(location)   << (8*3));
	w += (memoryRegion->read(location+1) << (8*2));
	w += (memoryRegion->read(location+2) << (8*1));
	w += (memoryRegion->read(location+3) << (8*0));
	return w;
}
