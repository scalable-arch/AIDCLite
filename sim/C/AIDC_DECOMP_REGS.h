/* ------------------------------------------------------------------------------------------------
 * C Headers for the AIDC register model
 * ------------------------------------------------------------------------------------------------ */
#ifndef _AIDC_DECOMP_REGS_H_
#define _AIDC_DECOMP_REGS_H_

#ifndef AIDC_DECOMP_BASE
#define AIDC_DECOMP_BASE                    0U
#endif /* AIDC_DECOMP_BASE */

#define REG_AIDC_DECOMP_VERSION_OFFSET      0U
#define REG_AIDC_DECOMP_VERSION_ADDR        (AIDC_DECOMP_BASE + REG_AIDC_DECOMP_VERSION_OFFSET)
#define REG_AIDC_DECOMP_GIT_OFFSET          4U
#define REG_AIDC_DECOMP_GIT_ADDR            (AIDC_DECOMP_BASE + REG_AIDC_DECOMP_GIT_OFFSET)
#define REG_AIDC_DECOMP_SRC_ADDR_OFFSET     16U
#define REG_AIDC_DECOMP_SRC_ADDR_ADDR       (AIDC_DECOMP_BASE + REG_AIDC_DECOMP_SRC_ADDR_OFFSET)
#define REG_AIDC_DECOMP_DST_ADDR_OFFSET     20U
#define REG_AIDC_DECOMP_DST_ADDR_ADDR       (AIDC_DECOMP_BASE + REG_AIDC_DECOMP_DST_ADDR_OFFSET)
#define REG_AIDC_DECOMP_LEN_OFFSET          24U
#define REG_AIDC_DECOMP_LEN_ADDR            (AIDC_DECOMP_BASE + REG_AIDC_DECOMP_LEN_OFFSET)
#define REG_AIDC_DECOMP_CMD_OFFSET          28U
#define REG_AIDC_DECOMP_CMD_ADDR            (AIDC_DECOMP_BASE + REG_AIDC_DECOMP_CMD_OFFSET)
#define REG_AIDC_DECOMP_STATUS_OFFSET       32U
#define REG_AIDC_DECOMP_STATUS_ADDR         (AIDC_DECOMP_BASE + REG_AIDC_DECOMP_STATUS_OFFSET)

#endif /* _AIDC_DECOMP_REGS_H_ */
