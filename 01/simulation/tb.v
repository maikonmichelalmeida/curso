module tb;
  reg tb_clk;
initial begin
   tb_clk = 1'b0;
   forever #10 tb_clk = ~tb_clk;
end
initial begin
 _if.rstn <= 1;
 _if.sel <= 0;
 #20 _if.rstn <= 1'b0;
 #20 _if.rstn <= 1'b1;
end 
   reg_if _if(tb_clk);
   reg_ctrl u0(_if);
initial begin
 test t0;
 t0 = new;
 t0.e0.vif = _if;
 t0.run();
end
initial begin
   $fsdbDumpfile ("reg_array.fsdb");
   $fsdbDumpvars (3,tb);

 #200 $finish;
end
endmodule 
