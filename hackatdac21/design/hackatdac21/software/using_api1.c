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

    uint32_t rdata, wdata; 

    //////////////////////////////////////////////////////
    // Data transfers to/from peripherals using DMA
    //////////////////////////////////////////////////////
    // DMA transfers data in chunks of 32 bits
    // To transfer 2*64 bits to AES0 as plain text:
    // Max length supported is 32*64 bits
    
    uint32_t wmdata[4]  = {0x99991111, 0x77773333,0x44441111, 0x66663333, } ;
    uint32_t rmdata[4]; 

    dma_transfer_to_perif(wmdata, AES0_PT_BASE, 0x4, 1); 

    // if the last argument is '1', then the api will return 
    // only at the completion of the data transfer, if it is any
    // other value, the api returns after giving the command to dma
    
    // lets see if the data got tranferred:
    dma_transfer_from_perif(AES0_PT_BASE, rmdata, 0x4, 1); 
    printf("Data read from multi read-write = %08x %08x %08x %08x\n", rmdata[0], rmdata[1], rmdata[2], rmdata[3]); 
   

    // similarly, we can use dma to transfer from peripheral to peripheral directy: 
    // dma_transfer_perif_to_perif(AES0_PT_BASE, AES0_ST_BASE, 0x1, 1);
    

    // send end to dma to stop the dma core from looking fr any more dma
    // commands
    dma_end();

    return;

}



