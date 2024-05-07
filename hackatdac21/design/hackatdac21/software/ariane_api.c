/////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  - This file is only to help the participants with basic API's to interact with the SoC
//  - You can also, write your own functions / modify the code here, to interact with the 
//    peripherals since all of this is considered as user space code.
//
/////////////////////////////////////////////////////////////////////////////////////////////////////


#include <stdio.h>
#include <string.h>

#include "ariane_api.h"


void my_delay(int wait_cycles) {
    for (int i=0; i<wait_cycles; i++)
        asm volatile ("nop \n\t") ;   
}

void rsa_write_prime_num(uint32_t *p_num){
  uint32_t syscall_id ;

  // provide prime number to generate keys for encryption and decryption
  syscall_id = SYS_RSA_WRITE_PNUM;
  register uintptr_t a0 asm ("a0") = (uintptr_t)(p_num);
  register uint32_t a7 asm ("a7") = (uint32_t)(syscall_id);
  asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a7)
    );

}

void rsa_write_msg_in(uint32_t *msg_in, uint32_t encry_decry){
  uint32_t syscall_id ;

  // encrypt or decrypt message
  syscall_id = SYS_RSA_WRITE_MSG_IN;

  register uintptr_t a0 asm ("a0") = (uintptr_t)(msg_in);
  register uint32_t a1 asm ("a1") = (uint32_t)(encry_decry);
  register uint32_t  a7 asm ("a7") = (uint32_t)(syscall_id);
  asm volatile ( "ecall"
                : 
                : "r" (a0), "r" (a1), "r" (a7)); 

}

void rsa_read_msg_out(uint32_t *msg_out){
  uint32_t syscall_id ;

  syscall_id = SYS_RSA_READ_MSG_OUT;
  register uintptr_t a3 asm ("a0") = (uintptr_t)(msg_out);
  register uint32_t a4 asm ("a7") = (uint32_t)(syscall_id);
  asm volatile ( "ecall"
                  : "=r" (a3)
                  : "r" (a4)
    );

}

void rng(uint32_t *randnum){
  uint32_t syscall_id ;

  // Wait for valid output
  syscall_id = SYS_RNG_WAIT;
  register  uint32_t a2 asm ("a7") = (uint32_t)(syscall_id);
  asm volatile ( "ecall"
                :
                : "r" (a2)
  );

  //read random value
  syscall_id = SYS_RNG_READ_DATA;
  register uintptr_t a3 asm ("a0") = (uintptr_t)(randnum);
  register uint32_t a4 asm ("a7") = (uint32_t)(syscall_id);
  asm volatile ( "ecall"
                  : "=r" (a3)
                  : "r" (a4)
    );
}


void rng_read_poly(uint32_t *poly128, uint32_t *poly64, uint32_t *poly32, uint32_t *poly16){
  uint32_t syscall_id ;

  syscall_id = SYS_RNG_READ_POLY;
  register uintptr_t a0 asm ("a0") = (uintptr_t)(poly128);
  register uintptr_t a1 asm ("a1") = (uintptr_t)(poly64);
  register uintptr_t a2 asm ("a2") = (uintptr_t)(poly32);
  register uintptr_t a3 asm ("a3") = (uintptr_t)(poly16);
  register uint32_t a4 asm ("a7") = (uint32_t)(syscall_id);
  asm volatile ( "ecall"
                  : "=r" (a0), "=r" (a1), "=r" (a2), "=r" (a3)
                  : "r" (a4)
    );
}

void rng_write_poly(uint32_t *poly128, uint32_t *poly64, uint32_t *poly32, uint32_t *poly16){
  uint32_t syscall_id ;
  
  syscall_id = SYS_RNG_WRITE_POLY;
  register uintptr_t a0 asm ("a0") = (uintptr_t)(poly128);
  register uintptr_t a1 asm ("a1") = (uintptr_t)(poly64);
  register uintptr_t a2 asm ("a2") = (uintptr_t)(poly32);
  register uintptr_t a3 asm ("a3") = (uintptr_t)(poly16);
  register uint32_t a4 asm ("a7") = (uint32_t)(syscall_id);
  asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a3), "r" (a4)
    );
}

void rng_write_seed(uint32_t *seed128){
  uint32_t syscall_id ;
  
  syscall_id = SYS_RNG_WRITE_SEED;
  register uintptr_t a0 asm ("a0") = (uintptr_t)(seed128);
  register uint32_t a1 asm ("a7") = (uint32_t)(syscall_id);
  asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1)
    );

}

void rng_read_seed(uint32_t *seed128, uint32_t *seed64, uint32_t *seed32, uint32_t *seed16){
  uint32_t syscall_id;
  
  // Wait for valid output
  syscall_id = SYS_RNG_WAIT;
  register  uint32_t a2 asm ("a7") = (uint32_t)(syscall_id);
  asm volatile ( "ecall"
                :
                : "r" (a2)
  );
  
  syscall_id = SYS_RNG_READ_SEED;
  register uintptr_t a0 asm ("a0") = (uintptr_t)(seed128);
  register uintptr_t a1 asm ("a1") = (uintptr_t)(seed64);
  register uint32_t  a3 asm ("a2") = (uintptr_t)(seed32);
  register uint32_t  a4 asm ("a3") = (uintptr_t)(seed16);
  register uint32_t  a5 asm ("a7") = (uint32_t)(syscall_id);
  asm volatile ( "ecall"
                : "=r" (a0), "=r" (a1), "=r" (a3), "=r" (a4)
                : "r" (a5)
  );

}

void rng_read_rand_seg(uint32_t *rand_seg){
  uint32_t syscall_id;
  
  // Wait for valid output
  syscall_id = SYS_RNG_WAIT;
  register  uint32_t a2 asm ("a7") = (uint32_t)(syscall_id);
  asm volatile ( "ecall"
                :
                : "r" (a2)
  );
  
  //read random seg
  syscall_id = SYS_RNG_READ_RAND_SEG;
  register uintptr_t a3 asm ("a0") = (uintptr_t)(rand_seg);
  register uint32_t a4 asm ("a7") = (uint32_t)(syscall_id);
  asm volatile ( "ecall"
                  : "=r" (a3)
                  : "r" (a4)
    );

}

void rng_read_state_counter(uint32_t *st_cnt){
  uint32_t syscall_id ;

  // Wait for valid output
  syscall_id = SYS_RNG_WAIT;
  register  uint32_t a2 asm ("a7") = (uint32_t)(syscall_id);
  asm volatile ( "ecall"
                :
                : "r" (a2)
  );

  //read random value
  syscall_id = SYS_RNG_READ_STATE_COUNTER;
  register uintptr_t a3 asm ("a0") = (uintptr_t)(st_cnt);
  register uint32_t a4 asm ("a7") = (uint32_t)(syscall_id);
  asm volatile ( "ecall"
                  : "=r" (a3)
                  : "r" (a4)
    );  
}

void aes0_decrypt(uint32_t *ct, uint32_t *st, uint32_t *pt, uint32_t key_sel) {

    uint32_t syscall_id ; 

    // Write the inputs and start AES decryption
    syscall_id = SYS_AES0_START_DECRY; 
    register uintptr_t a0 asm ("a0") = (uintptr_t)(ct);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(st);
    register uint32_t  a2 asm ("a2") = (uint32_t)(key_sel);
    register uint32_t  a3 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a3) ); 
    

    // Wait for valid output
    syscall_id = SYS_AES0_WAIT; 
    register uint32_t  a4 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : 
                  : "r" (a4) ); 
    
    // Read the plain data
    syscall_id = SYS_AES0_DATA_OUT; 
    register uintptr_t a6 asm ("a0") = (uintptr_t)(pt);
    register uint32_t  a7 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : "=r" (a6)
                  : "r" (a7) ); 
    return; 
}

void aes2_decrypt(uint32_t *ct, uint32_t *st, uint32_t *pt, uint32_t key_sel) {
    uint32_t syscall_id ; 
    
    // Write the inputs and start AES decryption
    syscall_id = SYS_AES2_START_DECRY; 
    register uintptr_t a0 asm ("a0") = (uintptr_t)(ct);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(st);
    register uint32_t  a2 asm ("a2") = (uint32_t)(key_sel);
    register uint32_t  a3 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a3) ); 
    

    // Wait for valid output
    syscall_id = SYS_AES2_WAIT; 
    register uint32_t  a4 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : 
                  : "r" (a4) ); 
    
    // Read the plain data
    syscall_id = SYS_AES2_DATA_OUT; 
    register uintptr_t a6 asm ("a0") = (uintptr_t)(pt);
    register uint32_t  a7 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : "=r" (a6)
                  : "r" (a7) ); 
    return; 
}

void rst_id(uint32_t id) {
    uint32_t syscall_id ;
    // Write the inputs and start AES decryption
    syscall_id = SYS_RST; 
    register uint32_t a0 asm ("a0") = (uint32_t)(id);
    register uint32_t  a1 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1)); 
  printf("sent reset signal to %u\n", id);
  return;
}

void aes0_encrypt(uint32_t *pt, uint32_t *st, uint32_t *ct, uint32_t key_sel) {

    uint32_t syscall_id ; 

    // Write the inputs and start AES encryption
    syscall_id =SYS_AES0_START_ENCRY; 
    register uintptr_t a0 asm ("a0") = (uintptr_t)(pt);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(st);
    register uint32_t  a2 asm ("a2") = (uint32_t)(key_sel);
    register uint32_t  a3 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a3) ); 
    

    // Wait for valid output
    syscall_id = SYS_AES0_WAIT; 
    register uint32_t  a4 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : 
                  : "r" (a4) ); 
    
    // Read the Encrypted data
    syscall_id = SYS_AES0_DATA_OUT; 
    register uintptr_t a5 asm ("a0") = (uintptr_t)(ct);
    register uint32_t  a6 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : "=r" (a5)
                  : "r" (a6) ); 
    return; 
}

void aes2_encrypt(uint32_t *pt, uint32_t *st, uint32_t *ct, uint32_t key_sel) {
    uint32_t syscall_id ; 

    // Write the inputs and start AES encryption
    syscall_id =SYS_AES2_START_ENCRY; 
    register uintptr_t a0 asm ("a0") = (uintptr_t)(pt);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(st);
    register uint32_t  a2 asm ("a2") = (uint32_t)(key_sel);
    register uint32_t  a3 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a3) ); 
    

    // Wait for valid output
    syscall_id = SYS_AES2_WAIT; 
    register uint32_t  a4 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : 
                  : "r" (a4) ); 
    
    // Read the Encrypted data
    syscall_id = SYS_AES2_DATA_OUT; 
    register uintptr_t a5 asm ("a0") = (uintptr_t)(ct);
    register uint32_t  a6 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : "=r" (a5)
                  : "r" (a6) ); 
    return; 

}




void aes1_read_data(uint32_t *result) {
    
    uint32_t syscall_id = SYS_AES1_READ_DATA; 
   
    register uintptr_t a0 asm ("a0") = (uintptr_t)(result);
    register uint32_t  a1 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : "=r" (a0)
                  : "r" (a1) ); 

    return; 
}
void aes1_write_data(uint32_t *block, uint32_t key_sel) {

    uint32_t syscall_id = SYS_AES1_WRITE_DATA; 
    register uintptr_t a0 asm ("a0") = (uintptr_t)(block);
    register uint32_t  a1 asm ("a1") = (uint32_t)(key_sel);
    register uint32_t  a3 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a3) ); 
    return; 
}
void aes1_read_config(uint32_t *config_o) {
    
    uint32_t syscall_id = SYS_AES1_READ_CONFIG; 
   
    register uintptr_t a0 asm ("a0") = (uintptr_t)(config_o);
    register uint32_t  a1 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : "=r" (a0)
                  : "r" (a1) ); 

    return; 
}
void aes1_write_config(uint32_t config_i) {

    uint32_t syscall_id = SYS_AES1_WRITE_CONFIG; 
    register uint32_t  a0 asm ("a0") = (uint32_t)(config_i);
    register uint32_t  a1 asm ("a7") = (uint32_t)(syscall_id);
    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1) ); 
    return; 
}


void sha256_hashString(char *pString, uint32_t *hash) {

    uint32_t syscall_id;  
    syscall_id = SYS_SHA256_HASH ; 

    register uintptr_t a0 asm ("a0") = (uintptr_t)(pString);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(hash);
    register uint32_t  a7 asm ("a7") = (uint32_t)(syscall_id);

    asm volatile ( "ecall"
                  : "=r" (a1)
                  : "r" (a0), "r" (a7) ); 

    return; 

}


void hmac_hashString(char *pString, uint32_t *hash, uint32_t use_key_hash) {

    uint32_t syscall_id  = SYS_HMAC_HASH; 

    register uintptr_t a0 asm ("a0") = (uintptr_t)(pString);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(hash);
    register uint32_t  a2 asm ("a2") = (uint32_t)(use_key_hash);
    register uint32_t  a7 asm ("a7") = (uint32_t)(syscall_id);

    asm volatile ( "ecall"
                  : "=r" (a1)
                  : "r" (a0), "r" (a2), "r" (a7) ); 

    return; 

}


void dma_transfer_to_perif(uint32_t *sAddress, uint64_t dAddress, uint32_t length, int wait) {
    
    uint32_t syscall_id  = SYS_DMA_COPY1; 

    register uintptr_t a0 asm ("a0") = (uintptr_t)(sAddress);
    register uint64_t a1 asm ("a1") = (uint64_t)(dAddress);
    register uint32_t a2 asm ("a2") = (uint32_t)(length-1);
    register uint32_t a3 asm ("a3") = (uint32_t)(wait);
    register uint32_t a7 asm ("a7") = (uint32_t)(syscall_id);

    asm volatile ( "ecall"
                  : "=r" (a1)
                  : "r" (a0), "r" (a2), "r" (a3), "r" (a7) ); 

    return; 
}

void dma_transfer_from_perif(uint64_t sAddress, uint32_t *dAddress, uint32_t length, int wait) {
    
    uint32_t syscall_id  = SYS_DMA_COPY2; 

    register uint64_t a0 asm ("a0") = (uint64_t)(sAddress);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(dAddress);
    register uint32_t a2 asm ("a2") = (uint32_t)(length-1); // if we want 5 blocks, we need send 4 to syscall as indexing starts from 0 in hardware
    register uint32_t a3 asm ("a3") = (uint32_t)(wait);
    register uint32_t a7 asm ("a7") = (uint32_t)(syscall_id);

    asm volatile ( "ecall"
                  : "=r" (a1)
                  : "r" (a0), "r" (a2), "r" (a3), "r" (a7) ); 

    return; 
}


void dma_transfer_from_perif_to_perif(uint64_t sAddress, uint64_t dAddress, uint32_t length, int wait) {
    
    uint32_t syscall_id  = SYS_DMA_COPY; 

    register uint64_t a0 asm ("a0") = (uint64_t)(sAddress);
    register uint64_t a1 asm ("a1") = (uint64_t)(dAddress);
    register uint32_t a2 asm ("a2") = (uint32_t)(length-1); // if we want 5 blocks, we need send 4 to syscall as indexing starts from 0 in hardware
    register uint32_t a3 asm ("a3") = (uint32_t)(wait);
    register uint32_t a7 asm ("a7") = (uint32_t)(syscall_id);

    asm volatile ( "ecall"
                  : "=r" (a1)
                  : "r" (a0), "r" (a2), "r" (a3), "r" (a7) ); 

    return; 
}

void dma_end(){
    
    uint32_t syscall_id  = SYS_DMA_END; 

    register uint32_t a7 asm ("a7") = (uint32_t)(syscall_id);

    asm volatile ( "ecall"
                  : 
                  : "r" (a7) ); 
    return; 
}

int compareMulti(uint32_t *expectedData, uint32_t receivedData, uint32_t block_size) {

    uint32_t syscall_id  = SYS_CMP; 
    uint32_t equality; 

    register uintptr_t a0 asm ("a0") = (uintptr_t)(expectedData);
    register uint32_t a1 asm ("a1") = (uint32_t)(receivedData);
    register uint32_t a2 asm ("a2") = (uint32_t)(block_size);
    register uintptr_t a3 asm ("a3") = (uintptr_t)(&equality);
    register uint32_t a7 asm ("a7") = (uint32_t)(syscall_id);

    asm volatile ( "ecall"
                  : "=r" (a3)
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a7) ); 

    return equality; 
}

void do_delay(int n){
    int i; 
    for (i=0;i<n;i++)
    {
        asm volatile ("nop");
    }
    return; 
}


