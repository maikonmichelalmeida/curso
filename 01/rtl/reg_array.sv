// Note that in this protocol, write data is provided
	// in a single clock along with the address while read
	// data is received on the next clock, and no transactions
	// can be started during that time indicated by "ready"
	// signal.
        module reg_ctrl(reg_if _if);
	reg ready_dly;
	wire ready_pe;
           
	parameter ADDR_WIDTH = 8;
	parameter DATA_WIDTH = 16;
	parameter DEPTH = 256;
	parameter RESET_VAL = 16'h1234;
	

         // Some memory element to store data for each addr
	
          reg [DATA_WIDTH-1:0] ctrl [DEPTH];
	
	
	// If reset is asserted, clear the memory element
	// Else store data to addr for valid writes
	// For reads, provide read data back
	always @ (posedge _if.tb_clk) begin
	if (!_if.rstn) begin
	for (int i = 0; i < DEPTH; i += 1) begin
	ctrl[i] <= RESET_VAL;
	end
	end else begin
	if (_if.sel & _if.ready & _if.wr) begin
	ctrl[_if.addr] <= _if.wdata;
	end
	
	if (_if.sel & _if.ready & !_if.wr) begin
	_if.rdata <= ctrl[_if.addr];
	end else begin
	_if.rdata <= 0;
	end
	end
	end
	
	// Ready is driven using this always block
	// During reset, drive ready as 1
	// Else drive ready low for a clock low
	// for a read until the data is given back
	always @ (posedge _if.tb_clk) begin
	if (!_if.rstn) begin
	_if.ready <= 1;
	end else begin
	if (_if.sel & ready_pe) begin
	_if.ready <= 1;
	end
	if (_if.sel & _if.ready & !_if.wr) begin
	_if.ready <= 0;
	end
	end
	end
	
	// Drive internal signal accordingly
	always @ (posedge _if.tb_clk) begin
	if (!_if.rstn) ready_dly <= 1;
	else ready_dly <= _if.ready;
	end
	
	assign ready_pe = ~_if.ready & ready_dly;
	endmodule
