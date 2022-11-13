`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:58:38 10/05/2022 
// Design Name: 
// Module Name:    pong 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Pong_Game(clk, rst_n, left1, right1, left2, right2, plus, minus, pause, Player1_win, Player2_win, LED_R, LED_C, digit_seg0, digit_seg1, digit_seg2);
  
  parameter     SEG1    =   8'b0000_0110, //parameters of 7-seg
                SEG2    =   8'b0101_1011,
                SEG3    =   8'b0100_1111,
                SEG4    =   8'b0110_0110,
                SEG5    =   8'b0110_1101,
                SEG6    =   8'b0111_1101,
                SEG7    =   8'b0000_0111,
                SEG8    =   8'b0111_1111,
                SEG9    =   8'b0110_0111,
                SEG0    =   8'b0011_1111,
					 SEGDEFAULT = 8'b0100_0000; //Display '-'

  input clk;
  input rst_n;
  input left1;
  input right1;
  input left2;
  input right2;
  input plus;
  input minus;
  input pause;
 
  output Player1_win; //1: Player1 win ; 0: game continue
  output Player2_win; //1: Player2 win ; 0: game continue
  output [7:0] LED_R; //row of the LED
  output [7:0] LED_C; //column of the LED
  output [7:0] digit_seg0; //Winnning Condition
  output [7:0] digit_seg1; //Score of Player1
  output [7:0] digit_seg2; //Score of Player2
       
  reg Player1_win;
  reg Player2_win;
  reg [7:0] LED_R;
  reg [7:0] LED_C;
  reg [7:0] digit_seg0;
  reg [7:0] digit_seg1;
  reg [7:0] digit_seg2;
  
  reg [2:0] R; //row of the ball 
  reg [2:0] C; //column of the ball
  reg [2:0] R_next; 
  reg [2:0] C_next; 
  reg v_Horizon; //1: go left ; 0: go right
  reg v_Vertical; //1: go down ; 0: go up
  reg v_Horizon_next; 
  reg v_Vertical_next;
  reg [2:0]board1; //board1 position(0-5)  
  reg [2:0]board1_next; 
  reg [2:0]board2; //board2 position(0-5)  
  reg [2:0]board2_next; 
  reg [4:0]scan_state;  //scan state to light up LED
  reg divid_clk; 
  reg [5:0] div_cnt;
  reg [3:0] score1;
  reg [3:0] score2;
  reg [3:0] winning_condition;
  reg [3:0] score1_next;
  reg [3:0] score2_next;
  reg [3:0] winning_condition_next;


	always @(posedge clk or negedge rst_n) //0-4: Normal Gameplay; 5-12: P1 Wins; 13-20: P2 Wins.
		if(rst_n==0)
			scan_state <= 0;
		else 
		begin
			if(Player1_win == 0 && Player2_win == 0) 
			begin
				if(scan_state == 5'd4)  
					scan_state <= 0;
				else
					scan_state <= scan_state+1;
			end
			else if(Player1_win == 1 && Player2_win == 0) 
			begin
				if(scan_state == 5'd12)  
					scan_state <= 5'd5;
				else
					scan_state <= scan_state+1;
			end
			else
			begin
				if(scan_state == 5'd20)  
					scan_state <= 5'd13;
				else
					scan_state <= scan_state+1;
			end
		end


	always @(posedge clk or negedge rst_n)   //scan state to light up LED (ball, board1, board2)
		if(rst_n==0)                            
			begin   //initialize LED
				LED_R <= 8'b00000000;
				LED_C <= 8'b00000000;
			end
		else
		    begin
		    if(scan_state == 5'd0) //scan_state = 0, light up ball
			    begin
				    case(R)
				    3'o0:
					    LED_R<=8'b00000001;
				    3'o1:
					    LED_R<=8'b00000010;
				    3'o2:
					    LED_R<=8'b00000100;
				    3'o3:
					    LED_R<=8'b00001000;
				    3'o4:
					    LED_R<=8'b00010000;
				    3'o5:
					    LED_R<=8'b00100000;
				    3'o6:
					    LED_R<=8'b01000000;
				    3'o7:
					    LED_R<=8'b10000000;
					default:
						LED_R<=8'b00000000;
					endcase
					
				    case(C)
				    3'o0:
					    LED_C<=8'b00000001;
				    3'o1:
					    LED_C<=8'b00000010;
				    3'o2:
					    LED_C<=8'b00000100;
				    3'o3:
					    LED_C<=8'b00001000;
				    3'o4:
					    LED_C<=8'b00010000;
				    3'o5:
					    LED_C<=8'b00100000;
				    3'o6:
					    LED_C<=8'b01000000;
				    3'o7:
					    LED_C<=8'b10000000;
					default:
						LED_R<=8'b00000000;
					endcase					
				end
			else if(scan_state == 5'd1) //scan_state= 1, light up board1
				begin
					case(board1)
						3'd0:
						begin
							LED_R<=8'b01000000;
							LED_C<=8'b00000111;
						end
						3'd1:
						begin
							LED_R<=8'b01000000;
							LED_C<=8'b00001110;
						end
						3'd2:
						begin
							LED_R<=8'b01000000;
							LED_C<=8'b00011100;
						end
						3'd3:
						begin
							LED_R<=8'b01000000;
							LED_C<=8'b00111000;
						end
						3'd4:
						begin
							LED_R<=8'b01000000;
							LED_C<=8'b01110000;
						end
						3'd5:
						begin
							LED_R<=8'b01000000;
							LED_C<=8'b11100000;
						end
						default:
						begin
							LED_R<=8'b00000000;
							LED_C<=8'b00000000;
						end
					endcase
				end   
			else if(scan_state == 5'd2)//scan_state= 2, light up board2
				begin
					case(board2)
						3'd0:
						begin
							LED_R<=8'b00000010;
							LED_C<=8'b00000111;
						end
						3'd1:
						begin
							LED_R<=8'b00000010;
							LED_C<=8'b00001110;
						end
						3'd2:
						begin
							LED_R<=8'b00000010;
							LED_C<=8'b00011100;
						end
						3'd3:
						begin
							LED_R<=8'b00000010;
							LED_C<=8'b00111000;
						end
						3'd4:
						begin
							LED_R<=8'b00000010;
							LED_C<=8'b01110000;
						end
						3'd5:
						begin
							LED_R<=8'b00000010;
							LED_C<=8'b11100000;
						end
						default:
						begin
							LED_R<=8'b00000000;
							LED_C<=8'b00000000;
						end
					endcase
				end  	
			else if(scan_state == 5'd3) //light up block
				begin
					LED_R <= 8'b00010000;
					LED_C <= 8'b00100100;
				end
			else if(scan_state == 5'd4) //light up block
				begin
					LED_R <= 8'b00001000;
					LED_C <= 8'b00100100;
				end
			else if(scan_state == 5'd5) //P1
				begin
					LED_R <= 8'b00000001;
					LED_C <= 8'b01000111;
				end
			else if(scan_state == 5'd6)
				begin
					LED_R <= 8'b00000010;
					LED_C <= 8'b01101001;
				end
			else if(scan_state == 5'd7)
				begin
					LED_R <= 8'b00000100;
					LED_C <= 8'b01011001;
				end
			else if(scan_state == 5'd8)
				begin
					LED_R <= 8'b00001000;
					LED_C <= 8'b01000111;
				end
			else if(scan_state == 5'd9)
				begin
					LED_R <= 8'b00010000;
					LED_C <= 8'b01000001;
				end
			else if(scan_state == 5'd10)
				begin
					LED_R <= 8'b00100000;
					LED_C <= 8'b01000001;
				end
			else if(scan_state == 5'd11)
				begin
					LED_R <= 8'b01000000;
					LED_C <= 8'b01000001;
				end
			else if(scan_state == 5'd12)
				begin
					LED_R <= 8'b10000000;
					LED_C <= 8'b11110001;
				end
			else if(scan_state == 5'd13) //P2
				begin
					LED_R <= 8'b00000001;
					LED_C <= 8'b01110111;
				end
			else if(scan_state == 5'd14)
				begin
					LED_R <= 8'b00000010;
					LED_C <= 8'b10001001;
				end
			else if(scan_state == 5'd15)
				begin
					LED_R <= 8'b00000100;
					LED_C <= 8'b10001001;
				end
			else if(scan_state == 5'd16)
				begin
					LED_R <= 8'b00001000;
					LED_C <= 8'b01000111;
				end
			else if(scan_state == 5'd17)
				begin
					LED_R <= 8'b00010000;
					LED_C <= 8'b00100001;
				end
			else if(scan_state == 5'd18)
				begin
					LED_R <= 8'b00100000;
					LED_C <= 8'b00010001;
				end
			else if(scan_state == 5'd19)
				begin
					LED_R <= 8'b01000000;
					LED_C <= 8'b00010001;
				end
			else
				begin
					LED_R <= 8'b10000000;
					LED_C <= 8'b11110001;
				end
			end

	always @(*) //control the position of ball
		    begin
			 if (pause) begin
				R_next=R;
				C_next=C;
			 end
			 else if(Player1_win == 0 && Player2_win == 0)
			 begin
				case({R,C})
					6'o00,6'o01,6'o02,6'o03,6'o04,6'o05,6'o06,6'o07: //if the ball in the first row, reset the ball
					begin
						R_next=3'o4;
						C_next=3'o6;
					end   
					6'o70,6'o71,6'o72,6'o73,6'o74,6'o75,6'o76,6'o77: //if the ball in the last row, reset the ball
					begin
						R_next=3'o3;
						C_next=3'o1;
					end       
					6'o10,6'o30,6'o40,6'o60: //left wall
					begin
						if(v_Vertical==1) 
						begin
							R_next=R+3'o1;
							C_next=3'o1;
						end
						else
						begin
							R_next=R-3'o1;
							C_next=3'o1;
						end
					end  
					6'o17,6'o37,6'o47,6'o67: //right wall
					begin
						if(v_Vertical==1)
						begin
							R_next=R+3'o1;
							C_next=3'o6;
						end
						else
						begin
							R_next=R-3'o1;
							C_next=3'o6;
						end
					end        
					//if ball in the fifth row 
					6'o50: 
					begin
						if(board1==0 || board1==1) //if hit the board1, rebound â†						
						begin
							R_next=R-3'o1;
							C_next=3'o1;
						end
						else
						begin
							R_next=R+3'o1;
							C_next=3'o1;
						end
					end			  
					6'o51:
					begin
						if(board1==0 || board1==1) //if hit the board1, rebound
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
						else if(board1==2)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end						
						else
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
					end
					6'o52:
					begin
						if(board1==0 || board1==1 || board1==2) //if hit the board1, rebound
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
						else if(board1==3)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end						
						else
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
					end
					6'o53:
					begin
						if(board1==1 || board1==2 || board1==3) //if hit the board1, rebound
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
						else if(board1==0)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end	
						else if(board1==4)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end						
						else
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
					end
					6'o54:
					begin
						if(board1==2 || board1==3 || board1==4) //if hit the board1, rebound
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
						else if(board1==1)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end	
						else if(board1==5)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end						
						else
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
					end
					6'o55:
					begin
						if(board1==3 || board1==4 || board1==5) //if hit the board1, rebound
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
						else if(board1==2)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end					
						else
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
					end
					6'o56:
					begin
						if(board1==4 || board1==5) //if hit the board1, rebound
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
						else if(board1==3)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end					
						else
						begin
							case({v_Horizon,v_Vertical}) 
								2'b01: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b11: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
					end
					6'o57:
					begin
						if(board1==4 || board1==5) //if hit the board1, rebound â†						
						begin
							R_next=R-3'o1;
							C_next=3'o6;
						end
						else
						begin
							R_next=R+3'o1;
							C_next=3'o6;
						end
					end	
					//if ball in the second row
					6'o20: 
					begin
						if(board2==0 || board2==1) //if hit the board2, rebound â†						
						begin
							R_next=R+3'o1;
							C_next=3'o1;
						end
						else
						begin
							R_next=R-3'o1;
							C_next=3'o1;
						end
					end			  
					6'o21:
					begin
						if(board2==0 || board2==1) //if hit the board2, rebound
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
						else if(board2==2)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end						
						else
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
					end
					6'o22:
					begin
						if(board2==0 || board2==1 || board2==2) //if hit the board2, rebound
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
						else if(board2==3)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end						
						else
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
					end
					6'o23:
					begin
						if(board2==1 || board2==2 || board2==3) //if hit the board2, rebound
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
						else if(board2==0)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end	
						else if(board2==4)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end						
						else
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
					end
					6'o24:
					begin
						if(board2==2 || board2==3 || board2==4) //if hit the board2, rebound
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
						else if(board2==1)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end	
						else if(board2==5)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end						
						else
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
					end
					6'o25:
					begin
						if(board2==3 || board2==4 || board2==5) //if hit the board2, rebound
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
						else if(board2==2)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end					
						else
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
					end
					6'o26:
					begin
						if(board2==4 || board2==5) //if hit the board2, rebound
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R+3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
						else if(board2==3)
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R+3'o1;
									C_next=C+3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end					
						else
						begin
							case({v_Horizon,v_Vertical}) 
								2'b00: // â†								
								begin
									R_next=R-3'o1;
									C_next=C+3'o1;
								end
								2'b10: // â†								
								begin
									R_next=R-3'o1;
									C_next=C-3'o1;
								end
								default:
								begin
									R_next=R;
									C_next=C;
								end
							endcase
						end
					end
					6'o27:
					begin
						if(board2==4 || board2==5) //if hit the board2, rebound â†						
						begin
							R_next=R+3'o1;
							C_next=3'o6;
						end
						else
						begin
							R_next=R-3'o1;
							C_next=3'o6;
						end
					end
					6'o32: //transfer
					begin
						case({v_Horizon,v_Vertical}) 
							2'b01: 
								begin
									R_next=3'o4;
									C_next=3'o6;
								end
							2'b11: 
								begin
									R_next=3'o4;
									C_next=3'o4;
								end
							default:
								begin
									R_next=R;
									C_next=C;
								end
						endcase
					end
					6'o42:
					begin
						case({v_Horizon,v_Vertical}) 
							2'b00: 
								begin
									R_next=3'o3;
									C_next=3'o6;
								end
							2'b10: 
								begin
									R_next=3'o3;
									C_next=3'o4;
								end
							default:
								begin
									R_next=R;
									C_next=C;
								end
						endcase
					end
					6'o35:
					begin
						case({v_Horizon,v_Vertical}) 
							2'b01: 
								begin
									R_next=3'o4;
									C_next=3'o3;
								end
							2'b11: 
								begin
									R_next=3'o4;
									C_next=3'o1;
								end
							default:
								begin
									R_next=R;
									C_next=C;
								end
						endcase
					end
					6'o45:
					begin
						case({v_Horizon,v_Vertical}) 
							2'b00: 
								begin
									R_next=3'o3;
									C_next=3'o3;
								end
							2'b10: 
								begin
									R_next=3'o3;
									C_next=3'o1;
								end
							default:
								begin
									R_next=R;
									C_next=C;
								end
						endcase
					end
					6'o31,6'o41,6'o34,6'o44: //Block Left Wall
					begin
						if(v_Vertical)
						begin
							R_next=R+3'o1;
							C_next=C-3'o1;
						end
						else
						begin
							R_next=R-3'o1;
							C_next=C-3'o1;
						end
					end
					6'o33,6'o43,6'o36,6'o46: //Block Right Wall
					begin
						if(v_Vertical)
						begin
							R_next=R+3'o1;
							C_next=C+3'o1;
						end
						else
						begin
							R_next=R-3'o1;
							C_next=C+3'o1;
						end
					end
					6'o11,6'o12,6'o13,6'o14,6'o15,6'o16,
					6'o61,6'o62,6'o63,6'o64,6'o65,6'o66: //normal position
					begin
						case({v_Horizon,v_Vertical}) 
							2'b00: // â†							
							begin
								R_next=R-3'o1;
								C_next=C+3'o1;
							end
							2'b01: // â†							
							begin
								R_next=R+3'o1;
								C_next=C+3'o1;
							end
							2'b10: // â†							
							begin
								R_next=R-3'o1;
								C_next=C-3'o1;
							end
							2'b11:  // â†							
							begin
								R_next=R+3'o1;
								C_next=C-3'o1;
							end
							default:
							begin
								R_next=R;
								C_next=C;
							end
						endcase
					end
					default:
						begin
							R_next=R;
							C_next=C;
						end
				endcase      
		    end
			 else 
				begin
					R_next=R;
					C_next=C;
				end
			 end

	always @(posedge clk or negedge rst_n) //control the position of board
		if(rst_n==0)
			begin
				board1_next <= 3'o2;
				board2_next <= 3'o3;
			end
		else
			begin
				if(pause) begin
					board1_next <= board1;
					board2_next <= board2;
				end
				else begin
				if((Player1_win==0) && (Player2_win==0))
					begin
						if(((board1==0)&&(left1==1)&&(right1==0))||((board1==5)&&(left1==0)&&(right1==1))) //board1 can't move   
							board1_next<=board1;  
						else if((left1==1)&&(right1==0)) //board1 move left
							board1_next<=board1 - 3'o1;
						else if((left1==0)&&(right1==1)) //board1 move right          
							board1_next<=board1 + 3'o1;  
					
						if(((board2==0)&&(left2==1)&&(right2==0))||((board2==5)&&(left2==0)&&(right2==1))) //board2 can't move   
							board2_next<=board2;  
						else if((left2==1)&&(right2==0)) //board2 move left
							board2_next<=board2 - 3'o1;
						else if((left2==0)&&(right2==1)) //board2 move right          
							board2_next<=board2 + 3'o1; 
					end
				else if((Player1_win==1) || (Player2_win==1))
					begin
						board1_next<=board1;
						board2_next<=board2;
					end
			end
			end


	always @(*) //control the v of ball 
	begin
	if(pause) begin
		v_Vertical_next=v_Vertical;
		v_Horizon_next=v_Horizon;
	end
	else begin
		if((Player1_win==0) && (Player2_win==0))
		begin
			case({R,C})
				6'o10,6'o30,6'o40,6'o60: //left wall
				begin
					v_Horizon_next=0;
					v_Vertical_next=v_Vertical;
				end
				6'o17,6'o37,6'o47,6'o67://right wall
				begin
					v_Horizon_next=1;
					v_Vertical_next=v_Vertical;
				end
				//if ball in the fifth row 
				6'o50: 
				begin
					if(board1==0 || board1==1) //if hit the board1, rebound
						begin
							v_Horizon_next=0;
							v_Vertical_next=0;
						end
					else
						begin
							v_Horizon_next=0;
							v_Vertical_next=1;
						end
				end
				6'o51:  
				begin
					if(board1==0 || board1==1) 
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=0;
						end
					else if(board1==2)
						begin
							if(v_Horizon==0)
								begin
									v_Horizon_next=1;
									v_Vertical_next=0;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=1;
								end	
						end
					else
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=1;
						end
				end
				6'o52:  
				begin
					if(board1==0 || board1==1 || board1==2) 
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=0;
						end
					else if(board1==3)
						begin
							if(v_Horizon==0)
								begin
									v_Horizon_next=1;
									v_Vertical_next=0;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=1;
								end	
						end
					else
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=1;
						end
				end				
				6'o53:  
				begin
					if(board1==1 || board1==2 || board1==3) 
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=0;
						end
					else if(board1==0)
						begin
							if(v_Horizon==1)
								begin
									v_Horizon_next=0;
									v_Vertical_next=0;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=1;
								end	
						end
					else if(board1==4)
						begin
							if(v_Horizon==0)
								begin
									v_Horizon_next=1;
									v_Vertical_next=0;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=1;
								end	
						end
					else
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=1;
						end
				end	
				6'o54:  
				begin
					if(board1==2 || board1==3 || board1==4) 
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=0;
						end
					else if(board1==1)
						begin
							if(v_Horizon==1)
								begin
									v_Horizon_next=0;
									v_Vertical_next=0;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=1;
								end	
						end
					else if(board1==5)
						begin
							if(v_Horizon==0)
								begin
									v_Horizon_next=1;
									v_Vertical_next=0;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=1;
								end	
						end
					else
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=1;
						end
				end		
				6'o55:  
				begin
					if(board1==3 || board1==4 || board1==5) 
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=0;
						end
					else if(board1==2)
						begin
							if(v_Horizon==1)
								begin
									v_Horizon_next=0;
									v_Vertical_next=0;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=1;
								end	
						end
					else
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=1;
						end
				end		
				6'o56:  
				begin
					if(board1==4 || board1==5) 
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=0;
						end
					else if(board1==3)
						begin
							if(v_Horizon==1)
								begin
									v_Horizon_next=0;
									v_Vertical_next=0;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=1;
								end	
						end
					else
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=1;
						end
				end					
				6'o57:
				begin
					if(board1==4 || board1==5) //if hit the board1, rebound
						begin
						v_Horizon_next=1;
						v_Vertical_next=0;
						end
					else
						begin
						v_Horizon_next=1;
						v_Vertical_next=1;
						end
				end
				//if ball in the second row
				6'o20: 
				begin
					if(board2==0 || board2==1) //if hit the board2, rebound
						begin
							v_Horizon_next=0;
							v_Vertical_next=1;
						end
					else
						begin
							v_Horizon_next=0;
							v_Vertical_next=0;
						end
				end
				6'o21:  
				begin
					if(board2==0 || board2==1) 
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=1;
						end
					else if(board2==2)
						begin
							if(v_Horizon==0)
								begin
									v_Horizon_next=1;
									v_Vertical_next=1;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=0;
								end	
						end
					else
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=0;
						end
				end
				6'o22:  
				begin
					if(board2==0 || board2==1 || board2==2) 
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=1;
						end
					else if(board2==3)
						begin
							if(v_Horizon==0)
								begin
									v_Horizon_next=1;
									v_Vertical_next=1;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=0;
								end	
						end
					else
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=0;
						end
				end				
				6'o23:  
				begin
					if(board2==1 || board2==2 || board2==3) 
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=1;
						end
					else if(board2==0)
						begin
							if(v_Horizon==1)
								begin
									v_Horizon_next=0;
									v_Vertical_next=1;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=0;
								end	
						end
					else if(board2==4)
						begin
							if(v_Horizon==0)
								begin
									v_Horizon_next=1;
									v_Vertical_next=1;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=0;
								end	
						end
					else
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=0;
						end
				end	
				6'o24:  
				begin
					if(board2==2 || board2==3 || board2==4) 
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=1;
						end
					else if(board2==1)
						begin
							if(v_Horizon==1)
								begin
									v_Horizon_next=0;
									v_Vertical_next=1;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=0;
								end	
						end
					else if(board2==5)
						begin
							if(v_Horizon==0)
								begin
									v_Horizon_next=1;
									v_Vertical_next=1;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=0;
								end	
						end
					else
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=0;
						end
				end		
				6'o25:  
				begin
					if(board2==3 || board2==4 || board2==5) 
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=1;
						end
					else if(board2==2)
						begin
							if(v_Horizon==1)
								begin
									v_Horizon_next=0;
									v_Vertical_next=1;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=0;
								end	
						end
					else
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=0;
						end
				end		
				6'o26:  
				begin
					if(board2==4 || board2==5) 
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=1;
						end
					else if(board2==3)
						begin
							if(v_Horizon==1)
								begin
									v_Horizon_next=0;
									v_Vertical_next=1;
								end
							else
								begin
									v_Horizon_next=v_Horizon;
									v_Vertical_next=0;
								end	
						end
					else
						begin
							v_Horizon_next=v_Horizon;
							v_Vertical_next=0;
						end
				end					
				6'o27:
				begin
					if(board2==4 || board2==5) //if hit the board2, rebound
						begin
						v_Horizon_next=1;
						v_Vertical_next=1;
						end
					else
						begin
						v_Horizon_next=1;
						v_Vertical_next=0;
						end
				end
				6'o00,6'o01,6'o02,6'o03,6'o04,6'o05,6'o06,6'o07: //Player1 scores
				begin
					v_Horizon_next=1;
					v_Vertical_next=1;
				end
				6'o70,6'o71,6'o72,6'o73,6'o74,6'o75,6'o76,6'o77: //Player2 scores
				begin
					v_Horizon_next=0;
					v_Vertical_next=0;
				end
				6'o31,6'o34,6'o41,6'o44: //Block Left Wall
				begin
					v_Horizon_next = 1;
					v_Vertical_next = v_Vertical;
				end
				6'o33,6'o36,6'o43,6'o46: //Block Right Wall
				begin
					v_Horizon_next = 0;
					v_Vertical_next = v_Vertical;
				end
				6'o11,6'o12,6'o13,6'o14,6'o15,6'o16,
				6'o32,6'o35,
				6'o42,6'o45,
				6'o61,6'o62,6'o63,6'o64,6'o65,6'o66: //normal position
				begin
					v_Horizon_next=v_Horizon;
					v_Vertical_next=v_Vertical;
				end
				default: 
				begin
					v_Horizon_next=v_Horizon;
					v_Vertical_next=v_Vertical;
				end 
			endcase
		end
		else if((Player1_win==1) || (Player2_win==1))
			begin
				v_Horizon_next=v_Horizon;
				v_Vertical_next=v_Vertical;
			end
		end
	end

	always @(posedge clk or negedge rst_n) //Player Scores
	begin
		if(rst_n == 0)
			begin
				score1_next <= 1'b0;
				score2_next <= 1'b0;
			end
		else
			begin
				case({R,C})
				6'o00,6'o01,6'o02,6'o03,6'o04,6'o05,6'o06,6'o07: //Player1 scores
				begin
					score1_next <= score1 + 4'b1;
					score2_next <= score2;
					end
				6'o70,6'o71,6'o72,6'o73,6'o74,6'o75,6'o76,6'o77: //Player2 scores
				begin
					score1_next <= score1;
					score2_next <= score2 + 4'b1;
				end
				endcase
			end
	end

	always @(*) //who is the winner?
		if(score1 >= winning_condition && score2 < winning_condition) 
			begin
				Player1_win = 1;
				Player2_win = 0;
			end
		else if(score2 >= winning_condition && score1 < winning_condition)
			begin
				Player1_win = 0;
				Player2_win = 1;
			end
		else if(score2 >= winning_condition && score1 < winning_condition)
			begin
				if(score1 > score2)
					begin
						Player1_win = 1;
						Player2_win = 0;
					end
				else if(score2 > score1)
					begin
						Player1_win = 0;
						Player2_win = 1;
					end
				else
					begin
						Player1_win = 0;
						Player2_win = 0;
					end
			end
		else 
			begin
				Player1_win = 0;
				Player2_win = 0;
			end
	
	always @(posedge clk or negedge rst_n)   //use plus and minus to control the winning condition
	begin
		if(rst_n == 0)
			begin
				winning_condition_next <= 4'b1;
			end
		else
			begin
				if(pause) //Players can only change the winning condition in the pause status
					begin
						if(plus && winning_condition < 4'd9) 
							winning_condition_next <= winning_condition + 4'd1;
						else if(minus && winning_condition > 4'd1)
							winning_condition_next <= winning_condition - 4'd1;
						//else
							//winning_condition_next <= winning_condition;
					end
				else
					winning_condition_next <= winning_condition;
			end
	end
   
	always @(*) //light up 7-seg of winning condition
	begin
		case(winning_condition)
			4'd0:digit_seg0 = SEG0;
			4'd1:digit_seg0 = SEG1;
			4'd2:digit_seg0 = SEG2;
			4'd3:digit_seg0 = SEG3;
			4'd4:digit_seg0 = SEG4;
			4'd5:digit_seg0 = SEG5;
			4'd6:digit_seg0 = SEG6;
			4'd7:digit_seg0 = SEG7;
			4'd8:digit_seg0 = SEG8;
			4'd9:digit_seg0 = SEG9;
			default:digit_seg0 = SEGDEFAULT;
		endcase
	end
	
	always @(*) //light up 7-seg of Player1's score
	begin
		case(score1)
			4'd0:digit_seg1 = SEG0;
			4'd1:digit_seg1 = SEG1;
			4'd2:digit_seg1 = SEG2;
			4'd3:digit_seg1 = SEG3;
			4'd4:digit_seg1 = SEG4;
			4'd5:digit_seg1 = SEG5;
			4'd6:digit_seg1 = SEG6;
			4'd7:digit_seg1 = SEG7;
			4'd8:digit_seg1 = SEG8;
			4'd9:digit_seg1 = SEG9;
			default:digit_seg1 = SEGDEFAULT;
		endcase
	end
	
		always @(*) //light up 7-seg of Player2's score
	begin
		case(score2)
			4'd0:digit_seg2 = SEG0;
			4'd1:digit_seg2 = SEG1;
			4'd2:digit_seg2 = SEG2;
			4'd3:digit_seg2 = SEG3;
			4'd4:digit_seg2 = SEG4;
			4'd5:digit_seg2 = SEG5;
			4'd6:digit_seg2 = SEG6;
			4'd7:digit_seg2 = SEG7;
			4'd8:digit_seg2 = SEG8;
			4'd9:digit_seg2 = SEG9;
			default:digit_seg2 = SEGDEFAULT;
		endcase
	end
	
	always @(posedge clk or negedge rst_n) //counter 64
		if(rst_n==0)
			div_cnt <= 6'd0;
		else if(div_cnt==6'd63)
			div_cnt <= 6'd0;
		else
			div_cnt<=div_cnt+6'd1;

	always @(posedge clk or negedge rst_n) //divid_clk = f/128
		if(rst_n==0)
			divid_clk <= 0;
		else if(div_cnt==6'd63)
			divid_clk <= ~divid_clk;

	always @(posedge divid_clk or negedge rst_n) //refresh all information
		if(rst_n==0)
		begin    //initialize ball position(5,3), board1(2), board2(3)
			R <= 3'o4;
			C <= 3'o1;
			v_Horizon <= 1'b1;
			v_Vertical <= 1'b0;
			board1 <= 3'o2;
			board2 <= 3'o3;
			winning_condition <= 4'b1;
			score1 <= 4'b0;
			score2 <= 4'b0;
		end
		else
		begin
			R <= R_next;
			C <= C_next;
			v_Horizon <= v_Horizon_next;
			v_Vertical <= v_Vertical_next;
			board1 <= board1_next;			
			board2 <= board2_next;
			score1 <= score1_next;
			score2 <= score2_next;
			winning_condition <= winning_condition_next;
		end
endmodule

