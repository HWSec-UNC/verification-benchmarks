/////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  - This file is only to help the participants with basic API's to interact with the SoC
//  - You can also, write your own functions / modify the code here, to interact with the 
//    peripherals since all of this is considered as user space code.
//
/////////////////////////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>

#include "ariane_api.h"

void main(void)
{
	printf("This code shows the usage of various APIs available for phase 2\n"); 
    
    // RNG
    // This RNG is a PRNG developed based on LFSR, which contains seed and polynomial numbers.
    // We use a fixed seed in our design due to the version of simulation tool. 
    // We assume the seed gets initialized randomly.
    // There are four entropy sources.
    // We will pick random segments from output of four entropy sources to generate a random number.
    // We develop multiple methods to combine random segmentsm which represented by the state counter.
    
    uint32_t randnum[2];
    // Get an output
    rng(randnum);

    printf("rand1 %08x, %08x\n", randnum[0], randnum[1]);
    
    // Verify all other api functions
    // Each array represents signal from 128 bits to 16bits
    uint32_t array128[4] = {0x11111111, 0x22222222, 0x33333333, 0x44444444};
    uint32_t array64[2] = {0x55555555, 0x66666666};
    uint32_t array32[1] = {0x77777777};
    uint32_t array16[1] = {0x88888888};
    
    
    // Manually write polynomial numbers
    // This api can allow us to update polynomial numbers for each entropy source.
    rng_write_poly(array128, array64, array32, array16);
    rng_read_poly(array128, array64, array32, array16);
    printf("poly %08x, %08x, %08x, %08x, %08x, %08x, %08x, %08x\n", array128[0], array128[1], array128[2], array128[3], array64[0], array64[1], array32[0], array16[0]);
    
    // Manually write seeds
    // Similarly we can update seeds.
    //rng_write_seed(array128);
    //rng_read_seed(array128, array64, array32, array16);
    //printf("seed %08x, %08x, %08x, %08x, %08x, %08x, %08x, %08x\n", array128[0], array128[1], array128[2], array128[3], array64[0], array64[1], array32[0], array16[0]);
    
    // Check random number segments
    // This api allows us to check random segments from four entropy sources. 
    rng_read_rand_seg(array128);
    printf("seed_seg %08x, %08x, %08x, %08x\n", array128[0], array128[1], array128[2], array128[3]);
    
    // Check combination states of random number segments
    rng_read_state_counter(array16);
    printf("state counter %08x\n", array16[0]);



}

