#include <stdio.h>
#include <stdint.h>

#define AIDC_DECOMP_BASE    0
#define ADIC_COMP_BASE      4096
#define MEM_BASE            (512*1024*1024)     // 512MB

#include "AIDC_COMP_REGS.h"
#include "AIDC_DECOMP_REGS.h"

// APIs for memory-mapped I/O
void write_reg(uint64_t addr, uint32_t wdata)
{
    *((uint32_t *)addr)     = wdata;
}

uint32_t read_reg(uint64_t addr)
{
    return *((uint32_t *)addr);
}

// APIs for memory read/write
void write_mem(uint64_t addr, uint32_t wdata)
{
    *((uint32_t *)addr)     = wdata;
}

uint32_t read_mem(uint64_t addr)
{
    return *((uint32_t *)addr);
}

// API for memory compression
int test_comp(uint32_t src_addr, uint32_t dst_addr, uint32_t len)
{
    uint32_t status;

    write_reg(REG_AIDC_COMP_SRC_ADDR_ADDR, src_addr);
    write_reg(REG_AIDC_COMP_DST_ADDR_ADDR, dst_addr);
    write_reg(REG_AIDC_COMP_LEN_ADDR, len);
    write_reg(REG_AIDC_COMP_CMD_ADDR, 1);

    for (int i=0; i<10000; i++) {
        status = read_reg(REG_AIDC_COMP_STATUS_ADDR);
        if (status==1) {
            return 0;
        }
    }

    return 1;
}

// API for memory decompression
int test_decomp(uint32_t src_addr, uint32_t dst_addr, uint32_t len)
{
    uint32_t status;

    write_reg(REG_AIDC_DECOMP_SRC_ADDR_ADDR, src_addr);
    write_reg(REG_AIDC_DECOMP_DST_ADDR_ADDR, dst_addr);
    write_reg(REG_AIDC_DECOMP_LEN_ADDR, len);
    write_reg(REG_AIDC_DECOMP_CMD_ADDR, 1);

    for (int i=0; i<10000; i++) {
        status = read_reg(REG_AIDC_DECOMP_STATUS_ADDR);
        if (status==1) {
            return 0;
        }
    }

    return 1;
}

#define TEST_DATA_SIZE      256

#define UNCOMP_DATA_BASE    MEM_BASE
#define COMP_DATA_BASE      (MEM_BASE + TEST_DATA_SIZE)
#define DECOMP_DATA_BASE    (MEM_BASE + 2 * TEST_DATA_SIZE)

uint32_t test_data[TEST_DATA_SIZE/4] = {
         0x00000025, 0x0000ffc3, 0xffb2ffe9, 0x00000000, 0x0076ffd5, 0x0057ffba, 0x006b0000, 0x0000ff8f,
         0x0000fff8, 0x0000ffef, 0x0000007c, 0x00710000, 0x002affa1, 0x00000000, 0x0000ffc4, 0xff83ffb3,
         0x0000ffd6, 0xffdf0000, 0x007f0006, 0x00040000, 0x0000ffda, 0xffa9ff99, 0x00000000, 0x0000ffdc,
         0x00000000, 0x00060046, 0x00310000, 0x00000000, 0x00000000, 0x00170005, 0x0000ffff, 0x00000000,
         0x0006ffab, 0x000a000f, 0xffac0000, 0x00000000, 0x0061ffc6, 0xffe10000, 0x0000ff96, 0x00000000,
         0x00000000, 0xffd0ff85, 0xffd00000, 0xffe10000, 0x00000000, 0xff870000, 0x00000026, 0xff99ffce,
         0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000004, 0xffa0ffdc, 0x00000000, 0x0000ffd1,
         0x00000004, 0x00260000, 0xffa50000, 0x0000ff8f, 0x0060ffd2, 0x0000005c, 0xffe40000, 0x0000ffe3};

// main test
int main()
{
    int result;

    for (int i=0; i<(TEST_DATA_SIZE/4); i++) {
        write_mem(UNCOMP_DATA_BASE+i*4, test_data[i]);
    }

    result = test_comp(UNCOMP_DATA_BASE, COMP_DATA_BASE, TEST_DATA_SIZE);
    if (result!=0) { printf("Compression timed-out"); return 1; }
    result = test_decomp(COMP_DATA_BASE, DECOMP_DATA_BASE, TEST_DATA_SIZE/2);
    if (result!=0) { printf("Decompression timed-out"); return 1; }

    for (int i=0; i<(TEST_DATA_SIZE/4); i++) {
        uint32_t read_data;

        read_data = read_mem(DECOMP_DATA_BASE+i*4);
        if (read_data != test_data[i]) {
            printf("Mismatch between the uncompressed and decompressed data");
            return 1;
        }
    }

    return 0;
}
