module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);


  input clk;
  input reset;
  input [3:0] cmd;
  input cmd_valid;
  input [7:0] IROM_Q;
  output IROM_rd;
  output [5:0] IROM_A;
  output IRAM_valid;
  output [7:0] IRAM_D;
  output [5:0] IRAM_A;
  output busy;
  output done;

  //state
  parameter IDLE=3'd0,
            R_DATA=3'd1,
            R_CMD=3'd2,
            EXECUTE=3'd3,
            STORE=3'd4,
            DONE=3'd5;

  //command
  parameter WRITE=4'd0,
            SHIFT_UP=4'd1,
            SHIFT_DOWN=4'd2,
            SHIFT_LEFT=4'd3,
            SHIFT_RIGHT=4'd4,
            MAX=4'd5,
            MIN=4'd6,
            AVE=4'd7,
            LEFT_ROTATION=4'd8,
            RIGHT_ROTATION=4'd9,
            MIRROR_X=4'd10,
            MIRROR_Y=4'd11;

  reg [2:0]state,n_state;
  reg [3:0]command;
  reg [7:0]dataIn[0:63];
  reg [5:0]addrCounter,n_addrCounter;
  reg [2:0]op_x,op_y,next_x,next_y;
  reg [7:0]next_LU,next_RU,next_LD,next_RD;
  reg [7:0]max,min,n_max,n_min;
  reg [9:0]psum,n_psum;
  reg [1:0]stage,n_stage;
  wire countEn,change_en,stage_en;
  wire [5:0]LU,LD,RU,RD;
  wire [7:0]ave;

  //output
  assign IROM_rd=(state==R_DATA)?1'b1:1'b0;
  assign IROM_A=(state==R_DATA)?addrCounter:6'd0;
  assign IRAM_valid=(state==STORE)?1'b1:1'b0;
  assign IRAM_A=(state==STORE)?addrCounter:6'd0;
  assign IRAM_D=(state==STORE)?dataIn[addrCounter]:8'd0;
  assign busy=(state==R_CMD||state==DONE)?1'b0:1'b1;
  assign done=(state==DONE)?1'b1:1'b0;

  //control signal
  assign countEn=(state==R_DATA||state==STORE)?1'b1:1'b0;
  assign change_en=(state==EXECUTE)?1'b1:1'b0;
  assign stage_en=(command==MAX||command==MIN||command==AVE)?1'b1:1'b0;

  //operation address
  assign RD={op_y,3'd0}+op_x;
  assign LD=RD-6'd1;
  assign RU=RD-6'd8;
  assign LU=RD-6'd9;

  //average
  assign ave=psum[9:2];

  //FSM
  always@(posedge clk or posedge reset)
  begin
    if(reset)
    begin
      state<=IDLE;
    end
    else
    begin
      state<=n_state;
    end
  end

  always@(*)
  begin
    case(state)
      IDLE:
      begin
        n_state=R_DATA;
      end
      R_DATA:
      begin
        if(addrCounter==6'd63)
        begin
          n_state=R_CMD;
        end
        else
        begin
          n_state=state;
        end
      end
      R_CMD:
      begin
        if(cmd==WRITE)
        begin
          n_state=STORE;
        end
        else
        begin
          n_state=EXECUTE;
        end
      end
      EXECUTE:
      begin
        case(command)
          MAX:
          begin
            if(stage==2'd3)
            begin
              n_state=R_CMD;
            end
            else
            begin
              n_state=state;
            end
          end
          MIN:
          begin
            if(stage==2'd3)
            begin
              n_state=R_CMD;
            end
            else
            begin
              n_state=state;
            end
          end
          AVE:
          begin
            if(stage==2'd3)
            begin
              n_state=R_CMD;
            end
            else
            begin
              n_state=state;
            end
          end
          default:
          begin
            n_state=R_CMD;
          end
        endcase
      end
      STORE:
      begin
        if(addrCounter==6'd63)
        begin
          n_state=DONE;
        end
        else
        begin
          n_state=state;
        end
      end
      DONE:
      begin
        n_state=state;
      end
      default:
      begin
        n_state=IDLE;
      end
    endcase
  end

  always@(posedge clk or posedge reset)
  begin
    if(reset)
    begin
      addrCounter<=6'd0;
    end
    else if(countEn)
    begin
      addrCounter<=n_addrCounter;
    end
    else
    begin
      addrCounter<=6'd0;
    end
  end

  always@(*)
  begin
    if(state==R_DATA||state==STORE)
    begin
      n_addrCounter=addrCounter+6'd1;
    end
    else
    begin
      n_addrCounter=addrCounter;
    end
  end

  //read data
  always@(posedge clk or posedge reset)
  begin
    if(reset)
    begin
      dataIn[0]<=8'd0;
      dataIn[1]<=8'd0;
      dataIn[2]<=8'd0;
      dataIn[3]<=8'd0;
      dataIn[4]<=8'd0;
      dataIn[5]<=8'd0;
      dataIn[6]<=8'd0;
      dataIn[7]<=8'd0;
      dataIn[8]<=8'd0;
      dataIn[9]<=8'd0;
      dataIn[10]<=8'd0;
      dataIn[11]<=8'd0;
      dataIn[12]<=8'd0;
      dataIn[13]<=8'd0;
      dataIn[14]<=8'd0;
      dataIn[15]<=8'd0;
      dataIn[16]<=8'd0;
      dataIn[17]<=8'd0;
      dataIn[18]<=8'd0;
      dataIn[19]<=8'd0;
      dataIn[20]<=8'd0;
      dataIn[21]<=8'd0;
      dataIn[22]<=8'd0;
      dataIn[23]<=8'd0;
      dataIn[24]<=8'd0;
      dataIn[25]<=8'd0;
      dataIn[26]<=8'd0;
      dataIn[27]<=8'd0;
      dataIn[28]<=8'd0;
      dataIn[29]<=8'd0;
      dataIn[30]<=8'd0;
      dataIn[31]<=8'd0;
      dataIn[32]<=8'd0;
      dataIn[33]<=8'd0;
      dataIn[34]<=8'd0;
      dataIn[35]<=8'd0;
      dataIn[36]<=8'd0;
      dataIn[37]<=8'd0;
      dataIn[38]<=8'd0;
      dataIn[39]<=8'd0;
      dataIn[40]<=8'd0;
      dataIn[41]<=8'd0;
      dataIn[42]<=8'd0;
      dataIn[43]<=8'd0;
      dataIn[44]<=8'd0;
      dataIn[45]<=8'd0;
      dataIn[46]<=8'd0;
      dataIn[47]<=8'd0;
      dataIn[48]<=8'd0;
      dataIn[49]<=8'd0;
      dataIn[50]<=8'd0;
      dataIn[51]<=8'd0;
      dataIn[52]<=8'd0;
      dataIn[53]<=8'd0;
      dataIn[54]<=8'd0;
      dataIn[55]<=8'd0;
      dataIn[56]<=8'd0;
      dataIn[57]<=8'd0;
      dataIn[58]<=8'd0;
      dataIn[59]<=8'd0;
      dataIn[60]<=8'd0;
      dataIn[61]<=8'd0;
      dataIn[62]<=8'd0;
      dataIn[63]<=8'd0;
    end
    else if(IROM_rd)
    begin
      dataIn[addrCounter]<=IROM_Q;
    end
    else if(change_en)
    begin
      dataIn[LU]<=next_LU;
      dataIn[RU]<=next_RU;
      dataIn[LD]<=next_LD;
      dataIn[RD]<=next_RD;
    end
    else
    begin
    end
  end

  //Read Command
  always@(posedge clk or posedge reset)
  begin
    if(reset)
    begin
      command<=4'd0;
    end
    else if(cmd_valid)
    begin
      command<=cmd;
    end
    else
    begin
    end
  end

  //change operation point
  always@(posedge clk or posedge reset)
  begin
    if(reset)
    begin
      op_x<=3'd4;
      op_y<=3'd4;
    end
    else if(change_en)
    begin
      op_x<=next_x;
      op_y<=next_y;
    end
    else
    begin
    end
  end
  always@(*)
  begin
    case(command)
      SHIFT_UP:
      begin
        if(op_y==3'd1)
        begin
          next_y=op_y;
        end
        else
        begin
          next_y=op_y-3'd1;
        end
        next_x=op_x;
      end
      SHIFT_DOWN:
      begin
        if(op_y==3'd7)
        begin
          next_y=op_y;
        end
        else
        begin
          next_y=op_y+3'd1;
        end
        next_x=op_x;
      end
      SHIFT_LEFT:
      begin
        if(op_x==3'd1)
        begin
          next_x=op_x;
        end
        else
        begin
          next_x=op_x-3'd1;
        end
        next_y=op_y;
      end
      SHIFT_RIGHT:
      begin
        if(op_x==3'd7)
        begin
          next_x=op_x;
        end
        else
        begin
          next_x=op_x+3'd1;
        end
        next_y=op_y;
      end
      default:
      begin
        next_x=op_x;
        next_y=op_y;
      end
    endcase
  end

  //change operation data
  always@(*)
  begin
    case(command)
      MAX:
      begin
        if(stage==2'd3)
        begin
          next_LU=max;
          next_RU=max;
          next_LD=max;
          next_RD=max;
        end
        else
        begin
          next_LU=dataIn[LU];
          next_RU=dataIn[RU];
          next_LD=dataIn[LD];
          next_RD=dataIn[RD];
        end
      end
      MIN:
      begin
        if(stage==2'd3)
        begin
          next_LU=min;
          next_RU=min;
          next_LD=min;
          next_RD=min;
        end
        else
        begin
          next_LU=dataIn[LU];
          next_RU=dataIn[RU];
          next_LD=dataIn[LD];
          next_RD=dataIn[RD];
        end
      end
      AVE:
      begin
        if(stage==2'd3)
        begin
          next_LU=ave;
          next_RU=ave;
          next_LD=ave;
          next_RD=ave;
        end
        else
        begin
          next_LU=dataIn[LU];
          next_RU=dataIn[RU];
          next_LD=dataIn[LD];
          next_RD=dataIn[RD];
        end
      end
      LEFT_ROTATION:
      begin
        next_LU=dataIn[RU];
        next_RU=dataIn[RD];
        next_LD=dataIn[LU];
        next_RD=dataIn[LD];
      end
      RIGHT_ROTATION:
      begin
        next_LU=dataIn[LD];
        next_RU=dataIn[LU];
        next_LD=dataIn[RD];
        next_RD=dataIn[RU];
      end
      MIRROR_X:
      begin
        next_LU=dataIn[LD];
        next_RU=dataIn[RD];
        next_LD=dataIn[LU];
        next_RD=dataIn[RU];
      end
      MIRROR_Y:
      begin
        next_LU=dataIn[RU];
        next_RU=dataIn[LU];
        next_LD=dataIn[RD];
        next_RD=dataIn[LD];
      end
      default:
      begin
        next_LU=dataIn[LU];
        next_RU=dataIn[RU];
        next_LD=dataIn[LD];
        next_RD=dataIn[RD];
      end
    endcase
  end

  // caculate stage
  always @(posedge clk or posedge reset)
  begin
    if(reset)
    begin
      stage<=2'd0;
    end
    else if(stage_en)
    begin
      stage<=n_stage;
    end
    else
    begin
      stage<=2'd0;
    end
  end
  always@(*)
  begin
    if(stage_en)
    begin
      n_stage=stage+2'd1;
    end
    else
    begin
      n_stage=stage;
    end
  end

  always@(posedge clk or posedge reset)
  begin
    if(reset)
    begin
      max<=8'd0;
      min<=8'd255;
      psum<=10'd0;
    end
    else if(stage_en)
    begin
      max<=n_max;
      min<=n_min;
      psum<=n_psum;
    end
    else
    begin
      max<=dataIn[LU];
      min<=dataIn[LU];
      psum<=dataIn[LU];
    end
  end

  // max, min, psum
  always@(*)
  begin
    if(command==MAX)
    begin
      case(stage)
        2'd0:
        begin
          if(max>dataIn[RU])
          begin
            n_max=max;
          end
          else
          begin
            n_max=dataIn[RU];
          end
        end
        2'd1:
        begin
          if(max>dataIn[LD])
          begin
            n_max=max;
          end
          else
          begin
            n_max=dataIn[LD];
          end
        end
        2'd2:
        begin
          if(max>dataIn[RD])
          begin
            n_max=max;
          end
          else
          begin
            n_max=dataIn[RD];
          end
        end
        default:
        begin
          n_max=max;
        end
      endcase
      n_min=min;
      n_psum=psum;
    end
    else if(command==MIN)
    begin
      case(stage)
        2'd0:
        begin
          if(min<dataIn[RU])
          begin
            n_min=min;
          end
          else
          begin
            n_min=dataIn[RU];
          end
        end
        2'd1:
        begin
          if(min<dataIn[LD])
          begin
            n_min=min;
          end
          else
          begin
            n_min=dataIn[LD];
          end
        end
        2'd2:
        begin
          if(min<dataIn[RD])
          begin
            n_min=min;
          end
          else
          begin
            n_min=dataIn[RD];
          end
        end
        default:
        begin
          n_min=min;
        end
      endcase
      n_max=max;
      n_psum=psum;
    end
    else if(command==AVE)
    begin
      case(stage)
        2'd0:
        begin
          n_psum=psum+dataIn[RU];
        end
        2'd1:
        begin
          n_psum=psum+dataIn[LD];
        end
        2'd2:
        begin
          n_psum=psum+dataIn[RD];
        end
        default:
        begin
          n_psum=psum;
        end
      endcase
      n_max=max;
      n_min=min;
    end
    else
    begin
      n_max=max;
      n_min=min;
      n_psum=psum;
    end
  end

endmodule
