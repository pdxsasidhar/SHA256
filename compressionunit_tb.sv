module memtest;
  
  parameter N=32;
  parameter A=0,B=1,C=2,D=3,E=4,F=5,G=6,H=7,K=12,W=13;
  
  logic [N-1:0][N-1:0] clear,Q;
  logic clock;
  logic [N][N] [$clog2(N*N+1)-1:0] sel;
  
  logic check;
  logic [31:0] check32;
  
  logic sumcheck,carrycheck;
  logic [31:0] check32a,check32b;
  
  memristor #(N) crossbar (clear,sel,clock,Q);
  
  
  initial begin
    clock=0;
    forever begin
      #2;
      clock=~clock;
    end
  end
  
  task print;
    foreach(Q[i])
      $display("%b",Q[i]);
    $display("\n");
  endtask
  
  task imply(input int a,b); //1 to N inputs A and B is from 0 to 7
    clear=0;foreach(sel[i,j]) sel[i][j]=N*N;
    sel[a/N][a%N]=b;
    @(negedge clock);
  endtask;
  
  
  task false(input int a);
    foreach(sel[i,j]) sel[i][j]=N*N;
    clear[a/N][a%N]=1'b1;
    @(negedge clock);
    clear=0;
  endtask
  
  task x_imply(input int a,b); //print col
    clear=0;foreach(sel[i,j]) sel[i][j]=N*N;
    for(int i=0;i<N;i++) begin
      sel[i][a]=b+i*N;
    end
    @(negedge clock);
  endtask
  
  task y_imply(input int a,b); //print row
    clear=0;foreach(sel[i,j]) sel[i][j]=N*N;
    for(int i=0;i<N;i++) begin
      sel[a][i]=b*N+i;
    end
    @(negedge clock);
  endtask
  
  task y_false(input int a);
    clear=0;foreach(sel[i,j]) sel[i][j]=N*N;
    for(int i=0;i<N;i++)
      clear[i][a]=1;
    @(negedge clock);
    clear=0;
  endtask
  
  task x_false(input int a);
    clear=0;foreach(sel[i,j]) sel[i][j]=N*N;
    for(int i=0;i<N;i++)
      clear[a][i]=1;
    @(negedge clock);
    clear=0;
  endtask
  
  task and2(input int in1,in2,wm,out);
    false(wm);
    false(out);
    imply(wm,in1);
    imply(wm,in2);
    imply(out,wm);
  endtask
  
  
  task chx(input int in1,in2,in3,wm1,wm2,out);
    y_false(wm1);y_false(wm2);y_false(out);
    x_imply(wm1,in1);
    x_imply(wm2,wm1);
    x_imply(wm2,in3);
    x_imply(out,wm2);
    x_imply(wm1,in2);
    x_imply(out,wm1);
    for(int i=0;i<N;i++) begin
      check=(~Q[i][in1]&Q[i][in3])|(Q[i][in1]&Q[i][in2]);
      if(check!==Q[i][out])
         $display("choose error %b %B %b %B %b",Q[i][in1],Q[i][in2],Q[i][in3],Q[i][out],check);
     end
    
  endtask
  
  task chy(input int in1,in2,in3,wm1,wm2,out);
    x_false(wm1);x_false(wm2);x_false(out);
    y_imply(wm1,in1);
    y_imply(wm2,wm1);
    y_imply(wm2,in3);
    y_imply(out,wm2);
    y_imply(wm1,in2);
    y_imply(out,wm1);
    @(negedge clock);
  endtask
  
   task majx(input int in1,in2,in3,wm1,wm2,out);//wm2 out
    y_false(wm1);y_false(out);y_false(wm2);
    x_imply(wm1,in2);
    x_imply(out,wm1);
    x_imply(wm2,in3);
    x_imply(out,wm2);
    y_false(wm2);
    x_imply(wm2,out);
    x_imply(wm2,in1);
    y_false(out);
    x_imply(out,wm2);
    x_imply(wm1,in3);
    x_imply(out,wm1);
     for(int i=0;i<N;i++) begin
       check=(Q[i][in1]&Q[i][in2])|(Q[i][in3]&Q[i][in2])|(Q[i][in1]&Q[i][in3]);
       if(check!=Q[i][out])
         $display("%b %B %b %B %b",Q[i][in1],Q[i][in2],Q[i][in3],Q[i][out],check);
     end
  endtask
  
  task majonebit(input int in1,in2,in3,wm1,wm2,out);//wm2 out
    false(wm1);
	false(out);
	false(wm2);
	imply(wm1,in2);
	imply(out,wm1);
	imply(wm2,in3);
	imply(out,wm2);
	false(wm2);
	imply(wm2,out);
	imply(wm2,in1);
	false(out);
	imply(out,wm2);
	imply(wm1,in3);
	imply(out,wm1);
  endtask
    
  
  task exorx2(input int in1,in2,wm1,wm2,wm3,out);
    y_false(wm1);y_false(wm2);y_false(out);y_false(wm3);
    x_imply(wm1,in1);
    x_imply(wm2,in2);
    x_imply(wm3,in1);
    x_imply(wm3,wm2);
    x_imply(out,wm3);
    y_false(wm3);
    x_imply(wm3,wm1);
    x_imply(wm3,in2);
    x_imply(out,wm3);
  endtask
  
  task exorx2onebit(input int in1,in2,wm1,wm2,wm3,out);
    false(wm1);false(wm2);false(out);false(wm3);
	imply(wm1,in1);
	imply(wm2,in2);
	imply(wm3,in1);
	imply(wm3,wm2);
	imply(out,wm3);
	false(wm3);
	imply(wm3,wm1);
	imply(wm3,in2);
	imply(out,wm3);
  endtask
  
  task xorxonebit(input int in1,in2,in3,wm1,wm2,wm3,wm4,out);
    exorx2onebit(in1,in2,wm1,wm2,wm3,wm4);
    exorx2onebit(wm4,in3,wm1,wm2,wm3,out);
  endtask
  
  task xorx(input int in1,in2,in3,wm1,wm2,wm3,wm4,out);
    exorx2(in1,in2,wm1,wm2,wm3,wm4);
    exorx2(wm4,in3,wm1,wm2,wm3,out);
    for(int i=0;i<N;i++) begin
      check=Q[i][in1]^Q[i][in3]^Q[i][in2];
      if(Q[i][out]!=check) $display("xor error"); end
  endtask
  
  task rotrx(input int a,b,z);
    for(int i=0;i<N;i++) 
      check32[i]=Q[i][a];
    clear=0;foreach(sel[i,j]) sel[i][j]=N*N;y_false(b);
    for(int i=N-1;i>=0;i--) begin
      if(i-z>=0) sel[i-z][b]=a+i*N;
      else sel[N+i-z][b]=a+i*N;
    end
    @(negedge clock);
    y_false(a);
    x_imply(a,b);
    check32=check32>>z | check32<<N-z;
    for(int i=0;i<N;i++) begin
      if(Q[i][a]!=check32[i]) $display("%b %B",Q[i][a],check32[i]); end
  
      
  endtask
  
  task shrx(input int a,b,z);
    
    rotrx(a,b,z);
    for(int i=N-1;i>=N-z;i--) begin
      false(a+i*N);end

  endtask
  
  task csa(input int a,b,c,wm1,wm2,wm3,sum,carry);
    xorx(a,b,c,wm1,wm2,wm3,carry,sum);
    majx(a,b,c,wm1,wm2,carry);
    
    for(int i=0;i<N;i++) begin
      {carrycheck,sumcheck} = Q[i][a]+Q[i][b]+Q[i][c];
      if({carrycheck,sumcheck}!={Q[i][carry],Q[i][sum]}) $display("csa error %d",i); end
  endtask
  
  task cpa(input int a,b,c,wm1,wm2,wm3,wm4,out);// 4 3
    y_false(c);
    exorx2onebit(a,b,wm1,wm2,wm3,out);//wm4out 3
    and2(a,b,wm1,c);//2
    
    for(int i=1;i<N;i++) begin
      xorxonebit(a+i*N,b+i*N,c+(i-1)*N,wm1+i*N,wm2+i*N,wm3+i*N,wm4+i*N,out+i*N);
      majonebit(a+i*N,b+i*N,c+(i-1)*N,wm1+i*N,wm2+i*N,c+i*N);
    end
    for(int i=0;i<N;i++) begin
      check32a[i]=Q[i][a];check32b[i]=Q[i][b]; end
    check32=check32a+check32b;
    for(int i=0;i<N;i++) begin
      if(Q[i][out] != check32[i]) $display("CPA");end
  endtask
  
  
  task E0(int a,r1,r2,r3,Ezero,w1,w2,w3,w4);
    y_false(r1);y_false(r2);y_false(r3);y_false(Ezero);
    y_false(w1);y_false(w2);y_false(w3);y_false(w4);
    x_imply(w1,a);
    x_imply(r1,w1);x_imply(r2,w1);x_imply(r3,w1);
    rotrx(r1,w1,2);rotrx(r2,w2,13);rotrx(r3,w3,22);
    xorx(r1,r2,r3,w1,w2,w3,w4,Ezero);
  endtask
  
  task E1(int a,r1,r2,r3,Eone,w1,w2,w3,w4);
    y_false(r1);y_false(r2);y_false(r3);y_false(Eone);
    y_false(w1);y_false(w2);y_false(w3);y_false(w4);
    x_imply(w1,a);
    x_imply(r1,w1);x_imply(r2,w1);x_imply(r3,w1);
    rotrx(r1,w1,6);rotrx(r2,w2,11);rotrx(r3,w3,25);
    xorx(r1,r2,r3,w1,w2,w3,w4,Eone);
  endtask
  
  
  bit flag;
  task randomwrite(input int x);
    y_false(x);
    for(int i=0;i<N;i++) begin
      flag = $random;
      if(flag) imply(x+i*N,N-1);
    end
  endtask
  
  task randomizevariables;
    false(N-1);
    randomwrite(A);randomwrite(B);randomwrite(C);randomwrite(D);
    randomwrite(E);randomwrite(F);randomwrite(G);randomwrite(H);
    randomwrite(W);randomwrite(K);
  endtask
  
      
    
    
 
  
  initial begin
    @(negedge clock);
    clear={N*N{1'b1}};
    @(negedge clock); //$display("%b",Q);
    clear=0;
    foreach(sel[i,j]) sel[i][j]=N*N;
    @(negedge clock);
    print();
    
    
    $display("randomization");
    randomizevariables();print();
    
    	
    //ALL MAJOR NON ADD OPERATIONS
    majx(A,B,C,14,15,8);
    chx(E,F,G,14,15,9);
    E0(A,14,15,16,10,17,18,19,20);
    E1(E,14,15,16,11,17,18,19,20);
    
    
   // for(int i=0;i<N;i++) $display("%b %b %b %b %b",Q[i][A],Q[i][14],Q[i][15],Q[i][16],Q[i][10]);
    
    //----------------------------
    
    //H + KT + W
    csa(H,K,W,16,17,18,14,15);
    
    //------------------------
    
    //H+K+W + ch and reassigning CDFG
    csa(14,15,9,16,17,18,19,20);
    x_imply(21,A);x_imply(22,B);x_imply(23,C);x_imply(24,E);x_imply(25,F);x_imply(26,G);
    
    //H+K+W+ch + E1
    csa(19,20,11,16,17,18,14,15);
    
    //H+K+W+ch+E1 + D
    csa(14,15,D,16,17,18,19,20);
    
    //cpa H+K+W+ch+E1 + D = E
    cpa(19,20,27,28,16,17,18,E);
    y_false(B);y_false(C);y_false(D);y_false(F);y_false(G);y_false(H);
    x_imply(B,21);x_imply(C,22);x_imply(D,23);x_imply(F,24);x_imply(G,25);x_imply(H,26);
    
    //csa H+K+W+ch+E1 + maj
    csa(8,14,15,16,17,18,19,20);
    
    //csa H+K+W+ch+E1+maj + E0
    csa(10,19,20,16,17,18,14,15);
    
    //cpa H+K+W+ch+E1+maj + E0 = A
    cpa(14,15,16,17,18,19,20,A);
    
    $display("DONE \n");
    print();
    
    
    
 
    $stop;
  end
  
endmodule 




  
