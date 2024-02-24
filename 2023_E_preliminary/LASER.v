module LASER (
input CLK,
input RST,
input [3:0] X,
input [3:0] Y,
output reg [3:0] C1X,
output reg [3:0] C1Y,
output reg [3:0] C2X,
output reg [3:0] C2Y,
output reg DONE);

reg [3:0] state;
reg [5:0] counter;
reg [3:0] point_x[39:0];
reg [3:0] point_y[39:0];

reg [4:0] max_points;
reg [4:0] tmp_max_points;


reg [1:0] iter;

reg [3:0] X1;
reg [3:0] Y1;
reg [3:0] X2;
reg [3:0] Y2; // circle center 0 : 1    1 : 2

reg circle; 


reg  [3:0] pos_x , pos_y , pos_x2 , pos_y2 , pos_x3 , pos_y3 , pos_x4, pos_y4 , pos_x5 , pos_y5 , pos_x6 , pos_y6;
reg In1,In2,In3,In4,In5,In6;

always@(*)begin
    if( ( pos_x == 4 && pos_y == 0 ) || (pos_x == 3 && pos_y <= 2 ) || (pos_x <= 2  && pos_y <= 3 ) || (pos_x == 0 && pos_y == 4) )  
        In1 = 1;
    else
        In1 = 0;       // point 1 in circle 1
    
    if( ( pos_x2 == 4 && pos_y2 == 0 ) || (pos_x2 == 3 && pos_y2 <= 2 ) || (pos_x2 <= 2  && pos_y2 <= 3 ) || (pos_x2 == 0 && pos_y2 == 4) )  
        In2 = 1;
    else
        In2 = 0;      // point 1 in circle 2
    
    if( ( pos_x3 == 4 && pos_y3 == 0 ) || (pos_x3 == 3 && pos_y3 <= 2 ) || (pos_x3 <= 2  && pos_y3 <= 3 ) || (pos_x3 == 0 && pos_y3 == 4) )  
        In3 = 1;
    else
        In3 = 0;       // point 2 in circle 1
    
    if( ( pos_x4 == 4 && pos_y4 == 0 ) || (pos_x4 == 3 && pos_y4 <= 2 ) || (pos_x4 <= 2  && pos_y4 <= 3 ) || (pos_x4 == 0 && pos_y4 == 4) )  
        In4 = 1;
    else
        In4 = 0;      // point 2 in circle 2

    if( ( pos_x5 == 4 && pos_y5 == 0 ) || (pos_x5 == 3 && pos_y5 <= 2 ) || (pos_x5 <= 2  && pos_y5 <= 3 ) || (pos_x5 == 0 && pos_y5 == 4) )  
        In5 = 1;
    else
        In5 = 0;       // point 3 in circle 1

    if( ( pos_x6 == 4 && pos_y6 == 0 ) || (pos_x6 == 3 && pos_y6 <= 2 ) || (pos_x6 <= 2  && pos_y6 <= 3 ) || (pos_x6 == 0 && pos_y6 == 4) )  
        In6 = 1;
    else
        In6 = 0;       // point 3 in circle 1        
end

always@(posedge CLK)begin
    if(RST)begin
        C1X <= 0;
        C1Y <= 0;
        C2X <= 0;
        C2Y <= 0;
        DONE <= 0;
        
        X1 <= 0;
        Y1 <= 0;
        X2 <= 2;
        Y2 <= 2;
        
        iter <= 0;
        circle <= 1;
        state <= 0;
        counter <= 0;
        max_points <=  0;
        tmp_max_points <= 0;
    end 
    else begin
        case(state)
            0: begin //read data
                    point_x[counter] <= X;
                    point_y[counter] <= Y;
                    
                    if(counter == 39)begin
                        counter <= 0;
                        state <= state + 1 ;  
                    end
                    else begin
                        counter <= counter + 1;
                    end              
                end
            1: begin
                    if (X1 > point_x[counter])  pos_x <= X1 -  point_x[counter];
                    else                        pos_x <= point_x[counter] - X1;
                    
                    if (Y1 > point_y[counter])  pos_y  <= Y1 -  point_y[counter];
                    else                        pos_y  <= point_y[counter] - Y1;

                    
                    counter <= counter + 1;
                    state   <= state + 1 ;
                end
            2: begin
                    
                    if (X1 > point_x[counter])  pos_x <= X1 -  point_x[counter];
                    else                        pos_x <= point_x[counter] - X1;
                   
                    if (Y1 > point_y[counter])  pos_y  <= Y1 -  point_y[counter];
                    else                        pos_y  <= point_y[counter] - Y1;

                    if (X1 > point_x[counter + 1])  pos_x3 <= X1 - point_x[counter + 1]; // distance counter + 1 to circle 1  
                    else                            pos_x3 <= point_x[counter + 1] - X1; 

                    if (Y1 > point_y[counter + 1])  pos_y3 <= Y1 -  point_y[counter + 1];
                    else                            pos_y3 <= point_y[counter + 1] - Y1;
                    //
                    if (X1 > point_x[counter + 2])  pos_x5 <= X1 - point_x[counter + 2]; // distance counter + 2 to circle 1  
                    else                            pos_x5 <= point_x[counter + 2] - X1; 

                    if (Y1 > point_y[counter + 2])  pos_y5 <= Y1 -  point_y[counter + 2];
                    else                            pos_y5 <= point_y[counter + 2] - Y1;
                    //
                    //
                    if (counter == 1) begin
                        if (In1) begin
                            tmp_max_points <= tmp_max_points + 1;
                        end
                    end else begin
                        if (In1 && In3 && In5) begin
                            tmp_max_points <= tmp_max_points + 3;
                        end
                        else if((In1 && In3 && !In5) || (In1 && !In3 && In5) || ( !In1 && In3 && In5) )begin
                            tmp_max_points <= tmp_max_points + 2;
                        end
                        else if( (In1 && !In3 && !In5) || (!In1 && In3 && !In5) || ( !In1 && !In3 && In5) ) begin
                            tmp_max_points <= tmp_max_points + 1;
                        end
                    end
                    
                    
                    if(counter >= 39)begin
                        counter <= 0;
                        state <= state + 1;
                    end
                    else begin
                        counter <= counter + 3;
                    end
                end
            3: begin
                    if(X1 == 13 && Y1 == 13)begin
                        state <= 4;
                        
                        X1 <= C1X;
                        Y1 <= C1Y;

                        X2 <= 2;
                        Y2 <= 2;
                        circle <= 1;
                    end
                    else begin
                        state <= 1;
                        if(X1 == 13)begin
                            X1 <= 2;
                            Y1 <= Y1 + 1;
                        end
                        else begin
                            X1 <= X1 + 1;
                        end
                    end

                    if(tmp_max_points > max_points)begin
                        C1X <= X1;
                        C1Y <= Y1;
                        max_points <= tmp_max_points;
                    end
              
                    tmp_max_points <= 0;
                   
                end
            4: begin // circle 2 start
                    if (X1 > point_x[counter])  pos_x <= X1 -  point_x[counter];
                    else                        pos_x <= point_x[counter] - X1;
                    if (Y1 > point_y[counter])  pos_y   <= Y1 -  point_y[counter];
                    else                        pos_y   <= point_y[counter] - Y1;
                    
                    
                    if (X2 > point_x[counter])  pos_x2 <= X2 -  point_x[counter];
                    else                        pos_x2 <= point_x[counter] - X2;
                    if (Y2 > point_y[counter])  pos_y2 <= Y2 - point_y[counter];
                    else                        pos_y2 <= point_y[counter] - Y2;
                    

                    
                    //

                    counter <= counter + 1;
                    state <= state + 1;
                end
            5: begin
                    if (X1 > point_x[counter])  pos_x <= X1 -  point_x[counter];
                    else                        pos_x <= point_x[counter] - X1;
                    if (Y1 > point_y[counter])  pos_y   <= Y1 -  point_y[counter];
                    else                        pos_y   <= point_y[counter] - Y1;
                    
                    
                    if (X2 > point_x[counter])  pos_x2 <= X2 -  point_x[counter];
                    else                        pos_x2 <= point_x[counter] - X2;
                    if (Y2 > point_y[counter])  pos_y2 <= Y2 - point_y[counter];
                    else                        pos_y2 <= point_y[counter] - Y2;
                    

                    if (X1 > point_x[counter + 1])  pos_x3 <= X1 - point_x[counter + 1]; // distance counter + 1 to circle 1  
                    else                            pos_x3 <= point_x[counter + 1] - X1; 
                    if (Y1 > point_y[counter + 1])  pos_y3 <= Y1 -  point_y[counter + 1];
                    else                            pos_y3 <= point_y[counter + 1] - Y1;
                           

                    if (X2 > point_x[counter + 1])  pos_x4 <= X2 -  point_x[counter + 1]; // distance counter + 1 to circle 2
                    else                            pos_x4 <= point_x[counter + 1] - X2;
                    if (Y2 > point_y[counter + 1])  pos_y4 <= Y2 - point_y[counter + 1];
                    else                            pos_y4 <= point_y[counter + 1] - Y2;
                    
                    if (X1 > point_x[counter + 2])  pos_x5 <= X1 - point_x[counter + 2]; // distance counter + 2 to circle 1  
                    else                            pos_x5 <= point_x[counter + 2] - X1; 
                    if (Y1 > point_y[counter + 2])  pos_y5 <= Y1 -  point_y[counter + 2];
                    else                            pos_y5 <= point_y[counter + 2] - Y1;

                    if (X2 > point_x[counter + 2])  pos_x5 <= X2 - point_x[counter + 2]; // distance counter + 2 to circle 1  
                    else                            pos_x5 <= point_x[counter + 2] - X2; 
                    if (Y2 > point_y[counter + 2])  pos_y5 <= Y2 -  point_y[counter + 2];
                    else                            pos_y5 <= point_y[counter + 2] - Y2;
                    /*
                    if ((In1 || In2) && ( In3  || In4 )) begin
                        tmp_max_points <= tmp_max_points + 2;
                    end
                    else if ((In1 || In2) || ( In3  || In4 )) begin
                        tmp_max_points <= tmp_max_points + 1;
                    end                   
                    */
                    if (counter == 1) begin
                        if ((In1 || In2)) begin
                            tmp_max_points <= tmp_max_points + 1;
                        end 
                    end 
                    else begin
                        if ((In1 || In2) && ( In3  || In4 )  && ( In5  || In6 ) ) begin
                            tmp_max_points <= tmp_max_points + 3;
                        end
                        else if ( ((In1 || In2) &&  ( In3  || In4 )  && !( In5  || In6 )) ||
                                ((In1 || In2) && !( In3  || In4 )  &&  ( In5  || In6 )) ||
                                (!(In1 || In2) &&  ( In3  || In4 )  &&  ( In5  || In6 )) )   begin
                            tmp_max_points <= tmp_max_points + 2;
                        end
                        else if ((In1 || In2) || ( In3  || In4 ) || ( In5  || In6 )) begin
                            tmp_max_points <= tmp_max_points + 1;
                        end 
                    end
                    


                    if(counter >= 39)begin
                        counter <= 0;
                        if(circle == 0)
                            state <= 6;
                        else
                            state <= 7;
                    end
                    else begin
                        counter <= counter + 3;
                    end
                end
	     6: begin
                    if(X1 >= 13 && Y1 >= 13)begin
                        X1 <= C1X;
                        Y1 <= C1Y;
                        X2 <= 2;
                        Y2 <= 2;
                        circle <= 1;

                        state <= 8;
                    end
                    else begin
                        if(X1 >= 13)begin
                            X1 <= 2;
                            Y1 <= Y1 + 1;
                        end
                        else begin
                            if(X2 - X1 < 5 && Y2 - Y1 < 4)
                                X1 <= X1 + 6;
                            else
                                X1 <= X1 + 1;
                        end
                        state <= 4; // add
                    end
                    
                    if(tmp_max_points > max_points)begin                     
                        C1X <= X1;
                        C1Y <= Y1;
                        max_points <= tmp_max_points;
                    end 
                    
                    tmp_max_points <= 0;

                end
            7: begin
                    if(X2 >= 13 && Y2 >= 13)begin
                        X1 <= 2;
                        Y1 <= 2;
                        X2 <= C2X;
                        Y2 <= C2Y;
                        circle <= 0;

                        state <= 8;
                    end
                    else begin
                        if(X2 >= 13)begin
                            X2 <= 2;
                            Y2 <= Y2 + 1;
                        end
                        else begin
                            if(X1 - X2 < 5 && Y1 - Y2 < 4)
                                X2 <= X2 + 6;
                            else
                                X2 <= X2 + 1;
                        end

                        state <= 4; // add
                    end

                    if(tmp_max_points >= max_points)begin
                            C2X <= X2;
                            C2Y <= Y2;
                        max_points <= tmp_max_points;
                    end 
                    
                    tmp_max_points <= 0;

                end
                8: begin                 
                    iter <= iter + 1;
                    if(iter == 3) begin
                        state <= 9;
                        DONE <= 1;
                    end
                    else begin
                        state <= 4;
                    end
                end
                9: begin
                        DONE <= 0;
                        state <= 0;
                        max_points <= 0;
                        tmp_max_points <= 0;
                        X1 <= 0;
                        Y1 <= 0;
                        C1X <= 0;
                        C1Y <= 0;
                        C2X <= 0;
                        C2Y <= 0;
                        counter <= 0;
                    end
        endcase
    end    

end
endmodule
