interface CPI_GLOBAL (input clk, int rst_n);
    logic                               txcon_req;
    logic                               rxcon_ack;
    logic                               rxdiscon_nack;
    logic                               rx_empty;
    logic                               fatal;
    logic                               viral;
    logic   [`CPI_EPOCH_ID_WIDTH-1:0]   epoch_id;
    logic   [`CPI_EPOCH_ID_WIDTH-1:0]   epoch_commit;
    logic   [`CPI_EPOCH_ID_WIDTH-1:0]   epoch_reject;


    modport AGENT (
        output          txcon_req, fatal, viral, epoch_id, epoch_commit, epoch_rejct,
        input           rxcon_ack, rxdiscon_nack, rx_empty
    );

    modport FABRIC (
        input           txcon_req, fatal, viral, epoch_id, epoch_commit, epoch_rejct,
        output          rxcon_ack, rxdiscon_nack, rx_empty
    );

    // synthesis translate_off
    task reset();

    endtask
    // synthesis translate_on
endinterface


module CXL_CTRL
(
        input               clk,
        input               rst_n,

        CPI_GLOBAL.AGENT    cpi_intf
);

    cpi_intf.txcon_req          = 1'b1;
