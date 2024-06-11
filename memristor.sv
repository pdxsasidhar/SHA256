module memristor #(parameter N=3)(input logic [N-1:0][N-1:0] clear, input logic [N][N][$clog2((N*N)+1)] sel, input logic clock, output logic [N-1:0][N-1:0] Q);
  
  logic [N-1:0][N-1:0] mem; //crossbar
  logic [N-1:0][N-1:0] Y; //output of the flipflops
  
  always_comb begin //generating the output of the muxes
    
    for(int i=0;i<N;i++) begin
      for(int j=0;j<N;j++) begin
        if(sel[i][j]!=N*N) Y[i][j]=mem[(sel[i][j]/N)][(sel[i][j]%N)];
        else Y[i][j]=1;
      end
    end
    
  end
    
  
  always_ff @ (posedge clock) begin //generating the outputs of the flipflops
    
    for(int i=0;i<N;i++) begin
      for(int j=0;j<N;j++) begin
        if(clear[i][j]) mem[i][j]<=0;
      else
        mem[i][j] <= ~Y[i][j] | mem[i][j];
        //$display("%d %b %b",i,Y[i],mem[i]);
      end
    end
    
  end
  
  assign Q=mem; //theoretically connected to a bus
  
endmodule

    
  
