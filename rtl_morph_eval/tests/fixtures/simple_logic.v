module simple_logic(input a, input b, input c, output y);
assign y = (a & b) | (a & c);
endmodule
