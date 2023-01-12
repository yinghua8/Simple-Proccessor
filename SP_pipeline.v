module SP(
	// INPUT SIGNAL
	clk,
	rst_n,
	in_valid,
	inst,
	mem_dout,
	// OUTPUT SIGNAL
	out_valid,
	inst_addr,
	mem_wen,
	mem_addr,
	mem_din
);



//------------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//------------------------------------------------------------------------

input                    clk, rst_n, in_valid;
input             [31:0] inst;
input  signed     [31:0] mem_dout;
output reg               out_valid;
output reg        [31:0] inst_addr;
output reg               mem_wen;
output reg        [11:0] mem_addr;
output reg signed [31:0] mem_din;

//------------------------------------------------------------------------
//   DECLARATION
//------------------------------------------------------------------------
reg [31:0]ZE, ZE2;
reg signed [31:0]SE, SE2;
reg signed[31:0]shift;
reg signed[31:0] SE_temp;
// REGISTER FILE, DO NOT EDIT THE NAME.
reg     [31:0] r      [0:31]; 
reg     [31:0] inst_reg, inst_reg2, inst_reg3, inst_reg4;
reg     [31:0] PC, PC2, data, data1, data2, data3, out;
reg     [0:0] temp, OV1, OV2, OV3, OV4, flag;
integer i, j;
reg     [11:0] mem_addr0;
//------------------------------------------------------------------------
//   DESIGN
//------------------------------------------------------------------------
always@ (posedge clk, negedge rst_n)
begin
    if(!rst_n)
    begin
        ZE <= 0;
        SE <= 0;
        shift <= 0;
        SE_temp <= 0;
        out_valid <= 0;
        inst_addr <= 0;
        inst_reg <= 0;
        inst_reg2 <= 0;
        inst_reg3 <= 0;
        inst_reg4 <= 0;
        mem_wen <= 1;
        mem_addr <= 0;
        mem_addr0 <= 0;
        mem_din <= 0;
        PC <= 0;
        PC2 <= 0;
        data <= 0;
        data1 <= 0;
        data2 <= 0;
        data3 <= 0; 
        out <= 0;
	    temp <= 0;
        OV1 <= 0;
        OV2 <= 0;
        OV3 <= 0;
        OV4 <= 0;
        flag <= 0;
        for(i = 0; i < 32; i = i + 1)
        begin
            r[i] <= 'b0;
        end
    end
    else
    begin
        if(in_valid == 1 || out_valid == 1)
        begin
            //pipeline 1
            inst_reg <= inst;
            if(in_valid == 1)   OV1 <= 1;
            else    OV1 <= 0;
            if(flag == 1)   inst_addr <= PC2;
            SE2 <= SE;
            ZE2 <= ZE;

            //pipeline 2
            data1 <= data;
            inst_reg2 <= inst_reg;
            if(flag != 1)   inst_addr <= PC;
            if(mem_wen == 0)    mem_wen <= 1;
            if(inst_reg[31:26] == 6'b000110)  mem_wen <= 0;  //store
            OV2 <= OV1;
            
            //pipeline 3
            data2 <= data1;
            inst_reg3 <= inst_reg2;
            mem_addr <= mem_addr0;
            OV3 <= OV2;
            
            //pipeline 4
            if(inst_reg3[31:26] == 'b000101)  out <= mem_dout;  //load
            else    out <= data2;
            inst_reg4 <= inst_reg3;
            out_valid <= OV3;
        end
        else    OV1 <= OV1;
    end
end

always @(*)
begin
    if(inst_reg4[31:26] == 'b000000)   r[inst_reg4[15:11]] = out;
    else if(inst_reg4[31:26] != 'b000110 && inst_reg4[31:26] != 'b000111 && inst_reg4[31:26] != 'b001000)    r[inst_reg4[20:16]] = out;   
    else temp = 0;
    ZE = inst[15:0];
    SE = $signed(inst[15:0]);
    shift = SE << 2;
    if(mem_wen == 0)    
    begin
        mem_din = data1;
    end
    if(inst[31:26] == 'b000111 && r[inst[25:21]] == r[inst[20:16]])  //beq
    begin
        flag = 1;
        PC2 = inst_addr + 4 + $signed(shift);
    end
    if(inst[31:26] == 'b001000 && r[inst[25:21]] != r[inst[20:16]])  //bne
    begin
        flag = 1;
        PC2 = inst_addr + 4 + $signed(shift);
    end
    case(inst_reg[31:26])
        'b000000:  //R type
        begin
            PC = inst_addr + 4;
            if(inst_reg[5:0] == 'b000000)  //and
            begin
                data = r[inst_reg[25:21]] & r[inst_reg[20:16]];
            end
            else if(inst_reg[5:0] == 'b000001)  //or
            begin
                data = r[inst_reg[25:21]] | r[inst_reg[20:16]];
            end
            else if(inst_reg[5:0] == 'b000010)  //add
            begin
                data = r[inst_reg[25:21]] + r[inst_reg[20:16]];
            end
            else if(inst_reg[5:0] == 'b000011)  //sub
            begin
                data = r[inst_reg[25:21]] - r[inst_reg[20:16]];
            end
            else if(inst_reg[5:0] == 'b000100)  //slt
            begin
                if($signed(r[inst_reg[25:21]]) < $signed(r[inst_reg[20:16]]))
                begin
                    data = 1;
                end
                else  data = 0;
            end
            else if(inst_reg[5:0] =='b000101)  //sll
            begin
                data = r[inst_reg[25:21]] << inst_reg[10:6];
            end
            else temp = 1;
        end
        'b000001:  //andi
        begin
            PC = inst_addr + 4;
            data = r[inst_reg[25:21]] & ZE2;
        end
        'b000010:  //ori
        begin
            PC = inst_addr + 4;
            data = r[inst_reg[25:21]] | ZE2;
        end
        'b000011:  //addi
        begin
            PC = inst_addr + 4;
            data = r[inst_reg[25:21]] + SE2;
        end
        'b000100:  //subi
        begin
            PC = inst_addr + 4;
            data = r[inst_reg[25:21]] - SE2;
        end
        'b000101:  //lw
        begin
            PC = inst_addr + 4;
            mem_addr0 = r[inst_reg[25:21]] + SE2;
        end
        'b000110:  //sw
        begin
            PC = inst_addr + 4;
            mem_addr0 = r[inst_reg[25:21]] + SE2;
            data = r[inst_reg[20:16]];
        end
        'b000111:  //beq
        begin
            if(flag != 1)
            begin
                PC = inst_addr + 4;
            end
            flag = 0;
        end
        'b001000:  //bne
        begin
            if(flag != 1)
            begin
                PC = inst_addr + 4;
            end
            flag = 0;  
        end
    endcase 
end
endmodule