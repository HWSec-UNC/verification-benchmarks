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

    //////////////////////////////////////////////////////
    // Using AES through API's:  
    //////////////////////////////////////////////////////
    
    uint32_t pt[4]  = {0x00000000, 0x00000000, 0x00000000, 0x00000100};
    uint32_t st[4]  = {0x22222222, 0x245e2ad5, 0x1988adb2, 0xe0761f34};
    uint32_t ct[AES0_CT_WORDS];
	uint32_t ct2[AES2_CT_WORDS];
	uint32_t pt0[AES0_CT_WORDS];
	uint32_t pt2[AES2_CT_WORDS];
	uint32_t pt3[AES2_CT_WORDS];
	
    uint32_t key_sel = 1; // can select one of the 3 keys by setting 0, 1 or 2 here
 
    // call AES encryption with key 0 
    aes0_encrypt( pt,  st,  ct,  key_sel); 

	// call AES2 (pt = plaintext, st = initial vector, ct = ciphertext output)
	aes2_encrypt( pt, st, ct2, key_sel);

    // print the ciphered text as output
    printf("aes0 enc %08x %08x %08x %08x\n", ct[0], ct[1], ct[2], ct[3]); 

    printf("aes2 enc %08x %08x %08x %08x\n", ct2[0], ct2[1], ct2[2], ct2[3]); 

	// similarly for decryption, we can do: 
	aes2_decrypt(ct2, st, pt3, key_sel);
    printf("aes2 dec %08x %08x %08x %08x\n", pt3[0], pt3[1], pt3[2], pt3[3]); 

    //aes0_decrypt( *ct,  *st,  *pt0,  key_sel, eng_sel);
    //aes2_decrypt( ct2,  st,  pt2,  key_sel);
    
    //printf("aes0 d %08x %08x %08x %08x\n", pt0[0], pt0[1], pt0[2], pt0[3]); 

    //printf("aes2 e %08x %08x %08x %08x\n", pt2[0], pt2[1], pt2[2], pt2[3]); 

	
    aes1_write_data(pt, 2); 
    aes1_write_config(1);  // encrption enable
    aes1_write_config(3);  // start = 1
    aes1_write_config(1);  // start = 0
    aes1_write_config(5);  // next = 1
    aes1_write_config(1);  // next = 0

    do_delay(300); 

    aes1_read_data(ct); 


    //////////////////////////////////////////////////////
    // Using SHA256 through API's:  
    //////////////////////////////////////////////////////

    char inputText[500] = "bittle trusts no one";  // inputText array can be of any length
    uint32_t hash[SHA256_HASH_WORDS];

    //  call SHA256 hashing
    sha256_hashString( inputText,  hash) ;

    // printing the first 4 words of hash (you can also print the rest similarly)
    printf("%08x %08x %08x %08x ... \n", hash[0], hash[1], hash[2], hash[3]); 


    //////////////////////////////////////////////////////
    // Using HMAC through API's:  
    //////////////////////////////////////////////////////

    // input text array has to have a fixed size of 64 characters = 256 bits
    char inputText1[65] = "----> this is the message for demo of hmac for hackadac'20 <----";  
    //uint32_t hash[HMAC_HASH_WORDS];
    uint32_t use_key_hash = 1; // 0 => use the standard key for hashing. 
                               // 1 => skip the hashing of key^pads and directly
                               // use the precomputed key hashes

    //  call HMAC hashing
    hmac_hashString( inputText1,  hash, use_key_hash) ;

    // printing the first 4 words of hash (you can also print the rest similarly)
    printf("%08x %08x %08x %08x ... \n", hash[0], hash[1], hash[2], hash[3]); 

  
}



