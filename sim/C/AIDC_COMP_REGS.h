/* ------------------------------------------------------------------------------------------------
 * C Headers for the AIDC register model
 * ------------------------------------------------------------------------------------------------ */
#ifndef _AIDC_COMP_REGS_H_
#define _AIDC_COMP_REGS_H_

#ifndef AIDC_COMP_BASE
#define AIDC_COMP_BASE                      0U
#endif /* AIDC_COMP_BASE */

#define REG_AIDC_COMP_VERSION_OFFSET        0U
#define REG_AIDC_COMP_VERSION_ADDR          (AIDC_COMP_BASE + REG_AIDC_COMP_VERSION_OFFSET)
#define REG_AIDC_COMP_GIT_OFFSET            4U
#define REG_AIDC_COMP_GIT_ADDR              (AIDC_COMP_BASE + REG_AIDC_COMP_GIT_OFFSET)
#define REG_AIDC_COMP_SRC_ADDR_OFFSET       16U
#define REG_AIDC_COMP_SRC_ADDR_ADDR         (AIDC_COMP_BASE + REG_AIDC_COMP_SRC_ADDR_OFFSET)
#define REG_AIDC_COMP_DST_ADDR_OFFSET       20U
#define REG_AIDC_COMP_DST_ADDR_ADDR         (AIDC_COMP_BASE + REG_AIDC_COMP_DST_ADDR_OFFSET)
#define REG_AIDC_COMP_LEN_OFFSET            24U
#define REG_AIDC_COMP_LEN_ADDR              (AIDC_COMP_BASE + REG_AIDC_COMP_LEN_OFFSET)
#define REG_AIDC_COMP_CMD_OFFSET            28U
#define REG_AIDC_COMP_CMD_ADDR              (AIDC_COMP_BASE + REG_AIDC_COMP_CMD_OFFSET)
#define REG_AIDC_COMP_STATUS_OFFSET         32U
#define REG_AIDC_COMP_STATUS_ADDR           (AIDC_COMP_BASE + REG_AIDC_COMP_STATUS_OFFSET)

#endif /* _AIDC_COMP_REGS_H_ */
