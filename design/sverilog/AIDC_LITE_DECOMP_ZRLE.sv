/*
module AIDC_LITE_DECOMP_ZRLE (
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        clk,
    input   wire                        rst_n,

    // no backpressure
    input   wire                        valid_i,
    input   wire                        sop_i,
    input   wire                        eop_i,
    input   wire    [63:0]              data_i,

    output  logic                       valid_o,
    output  logic   [2:0]               addr_o,
    output  logic   [63:0]              data_o,
    output  logic                       done_o
);
*/
module ZRLE_DECOMP (
	input wire				rst_n,
	input wire				clk,
	
	input wire 				valid_i,
	input wire [63:0]			data_i,
	input wire				sop_i,
	input wire				eop_i,
	
	input wire				ready_i,

	output wire				ready_o,
	output wire				sop_o,
	output wire 				eop_o,
	
	output wire				valid_o,
	output wire [63:0]			data_o
);


	reg [6:0]				size, size_n, size_nn;
	reg [127:0]				code_buf, code_buf_n, code_buf_nn;		
	// shift buffer => will be full => output ready = 0
	
	reg 					ready;
	reg [63:0] 				data_out, data_out_n;
	reg 					sop;
	reg 					eop;	
	reg 					valid_out, valid_out_n;
    reg                     done,done_n;
	// output data at next cycle is valid => valid_out_n = 1
	
	reg [3:0]				in_bcnt, in_bcnt_n;		// burst count
	reg [3:0] 				out_bcnt, out_bcnt_n;
	// Seqen //////////////////////////////////////////////
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			size 		<= 'b0;
			code_buf 	<= 'b0;
			data_out 	<= 'b0;
			valid_out	<= 'b0;
			in_bcnt		<= 'b0;
			out_bcnt 	<= 'b0;
			done 	<= 'b0;
		end
        else if(ready_i) begin
            size 		<= size_nn;
			code_buf 	<= code_buf_nn;
			data_out 	<= data_out_n;
		
			valid_out 	<= valid_out_n;
			in_bcnt 	<= in_bcnt_n;
			out_bcnt	<= out_bcnt_n;

			done		<= done_n;
        end 
		else begin
			size 		<= size;
			code_buf 	<= code_buf;
			data_out 	<= data_out;
		
			valid_out 	<= valid_out;
			in_bcnt 	<= in_bcnt;
			out_bcnt	<= out_bcnt;

			done		<= done_n;
		end
	end
	///////////////////////////////////////////////////////
	// rstn 	____----------------------------------------
	// clk		____----____----____----____----____----____
	// data_i	____x=======x=======x===============x=======
	// valid_i	____----------------------------------------
	// ready	____----------------________----------------
	// 
	// data_o	____________x=======x=======x=======x=======
	// valid_o	____________--------------------------------
	// Comb ///////////////////////////////////////////////
	always @(*) begin
		data_out_n 	= data_out;
		in_bcnt_n	= in_bcnt;
		out_bcnt_n 	= out_bcnt;
		valid_out_n	= 0;
		size_nn 	= size_n;
		size_n		= size;
		code_buf_nn	= code_buf_n;
		code_buf_n	= code_buf;
		done_n		= done;
        
        // 
		if ((!valid_out | (valid_out & ready_i)) & !done_n) begin // & (in_bcnt > out_bcnt)
			casez (code_buf[127:122])
				6'b000000: begin
					if (size >= 'd6) begin
						data_out_n = 64'b0;
						valid_out_n = 1'b1;
						size_n = size - 6;
						code_buf_n = code_buf << 6;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b000001: begin
					if (size >= 'd22) begin
						data_out_n = {16'b0, 16'b0, 16'b0, code_buf[121:106]};
						valid_out_n = 1'b1;
						size_n = size - 22;
						code_buf_n = code_buf << 22;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b00001?: begin
					if (size >= 'd21) begin
						data_out_n = {16'b0, 16'b0, code_buf[122:107], 16'b0};
						valid_out_n = 1'b1;
						size_n = size - 21;
						code_buf_n = code_buf << 21;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b00010?: begin
					if (size >= 'd21) begin
						data_out_n = {16'b0, code_buf[122:107], 16'b0, 16'b0};
						valid_out_n = 1'b1;
						size_n = size - 21;
						code_buf_n = code_buf << 21;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b00011?: begin
					if (size >= 'd21) begin
						data_out_n = {code_buf[122:107], 16'b0, 16'b0, 16'b0};
						valid_out_n = 1'b1;
						size_n = size - 21;
						code_buf_n = code_buf << 21;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b0010??: begin
					if (size >= 'd36) begin
						data_out_n = {16'b0, 16'b0, code_buf[123:108], code_buf[107:92]};
						valid_out_n = 1'b1;
						size_n = size - 36;
						code_buf_n = code_buf << 36;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b0011??: begin
					if (size >= 'd36) begin
						data_out_n = {16'b0, code_buf[123:108], 16'b0, code_buf[107:92]};
						valid_out_n = 1'b1;
						size_n = size - 36;
						code_buf_n = code_buf << 36;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b0100??: begin
					if (size >= 'd36) begin
						data_out_n = {code_buf[123:108], 16'b0, 16'b0, code_buf[107:92]};
						valid_out_n = 1'b1;
						size_n = size - 36;
						code_buf_n = code_buf << 36;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b0101??: begin
					if (size >= 'd36) begin
						data_out_n = {16'b0, code_buf[123:108], code_buf[107:92], 16'b0};
						valid_out_n = 1'b1;
						size_n = size - 36;
						code_buf_n = code_buf << 36;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b0110??: begin
					if (size >= 'd36) begin
						data_out_n = {code_buf[123:108], 16'b0, code_buf[107:92], 16'b0};
						valid_out_n = 1'b1;
						size_n = size - 36;
						code_buf_n = code_buf << 36;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b0111??: begin
					if (size >= 'd36) begin
						data_out_n = {code_buf[123:108], code_buf[107:92], 16'b0, 16'b0};
						valid_out_n = 1'b1;
						size_n = size - 36;
						code_buf_n = code_buf << 36;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b1000??: begin
					if (size >= 'd52) begin
						data_out_n = {16'b0, code_buf[123:108], code_buf[107:92], code_buf[91:76]};
						valid_out_n = 1'b1;
						size_n = size - 52;
						code_buf_n = code_buf << 52;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b1001??: begin
					if (size >= 'd52) begin
						data_out_n = {code_buf[123:108], 16'b0, code_buf[107:92], code_buf[91:76]};
						valid_out_n = 1'b1;
						size_n = size - 52;
						code_buf_n = code_buf << 52;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b1010??: begin
					if (size >= 'd52) begin
						data_out_n = {code_buf[123:108], code_buf[107:92], 16'b0, code_buf[91:76]};
						valid_out_n = 1'b1;
						size_n = size - 52;
						code_buf_n = code_buf << 52;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b1011??: begin
					if (size >= 'd52) begin
						data_out_n = {code_buf[123:108], code_buf[107:92], code_buf[91:76], 16'b0};
						valid_out_n = 1'b1;
						size_n = size - 52;
						code_buf_n = code_buf << 52;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				6'b11????: begin
					if (size >= 'd66) begin
						data_out_n = code_buf[125:62];
						valid_out_n = 1'b1;
						size_n = size - 66;
						code_buf_n = code_buf << 66;
						out_bcnt_n = out_bcnt + 1;
					end
				end
				// default: begin
				// 	valid_out_n = 1'b0;
				// end
			endcase
        	end
		else if (done_n) begin
			data_out_n = 0;
			valid_out_n = 0;
			size_n = 0;
			code_buf = 0;
		end
		else begin
			code_buf_n = code_buf;
			size_n = size;
		end
		// output burst sart & end signal sop_o & eop_o
		sop = (out_bcnt == 'd1 & valid_out & !done_n);
		eop = (out_bcnt == 'd0 & valid_out);

		if (size_n >= 'd64) begin
			ready = 1'b0;
		end
        	else if(done_n) begin
            ready = 1'b1;
        	end
		else begin
			if (in_bcnt >= 8) begin
				ready = 1'b0;
			end
			else	ready = 1'b1;
		end

		if (valid_i & ready) begin
			if (sop_i) begin
				code_buf_nn = code_buf_n | (data_i[61:0] << (66 - size_n)); // 1번 sop일 때, 62bit 전송. code_buf_nn  = {data_i,66{0}}; 
				size_nn = size_n + 62;  // 22.09.21                         // size 62bit
				out_bcnt_n = 0;
				done_n = 0;
			end
			else begin
                 if(eop_i & done_n) begin
                     done_n = 1'b0;
                 end
                 else if(eop_i & !done_n) begin
                     code_buf_nn = code_buf_n | (data_i << (64 - size_n));
			      size_nn = size_n + 64;
                 end
                 else begin
                    code_buf_nn = code_buf_n | (data_i << (64 - size_n));
				size_nn = size_n + 64;
                 end
            	end                                                     // eop 일 때 
			in_bcnt_n = in_bcnt + 1;
		end
		else begin
			code_buf_nn = code_buf_n;
			size_nn = size_n;
		end
		
		if (eop) begin
			in_bcnt_n = 0;
			code_buf_nn = 0;
			size_nn = 0;
            size_n = 0;     // 22.09.21
            size = 0;       // 22.09.21
            done_n = 1;       // 22.09.21
          end
	end
	///////////////////////////////////////////////////////
	
	assign ready_o 	= ready;
	assign data_o 	= data_out;
	assign valid_o 	= valid_out;
	assign sop_o 	= sop;
	assign eop_o 	= eop;

endmodule


