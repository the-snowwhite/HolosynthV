package utils;
/****************************************************************
* Log2 Function (taken from lecture of Juinn-Dar Huang)
* Note: This function actually yields ceil(log2(x+1)) 
*****************************************************************/
function integer clogb2;
	input [31:0] value;
	integer i;
   begin
		i = (value>1) ? (value-1) : (value);
		for (clogb2=0; i>0; clogb2=clogb2+1)
			i = i>>1;
	end
endfunction

//ceil of the log base 2
function integer clog2;
    input [31:0] Depth;
    integer i;
    begin
         i = Depth;        
        for(clog2 = 0; i > 0; clog2 = clog2 + 1)
            i = i >> 1;
    end
endfunction

endpackage

