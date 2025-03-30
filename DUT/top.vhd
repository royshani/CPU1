LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
-------------------------------------
ENTITY top IS
  GENERIC (n : INTEGER := 8;
		   k : integer := 3;   -- k=log2(n)
		   m : integer := 4	); -- m=2^(k-1)
  PORT 
  (  
	Y_i,X_i: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		  ALUFN_i : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		  ALUout_o: OUT STD_LOGIC_VECTOR(n-1 downto 0);
		  Nflag_o,Cflag_o,Zflag_o,Vflag_o: OUT STD_LOGIC -- Zflag,Cflag,Nflag,Vflag
		  ); 
END top;
------------- complete the top Architecture code --------------
ARCHITECTURE struct OF top IS 
	------* ALL COMPONENT DECLERATIONS ARE WITHIN AUX_PACKAGE.VHD *------

	SIGNAL arith_out, shifter_out, logic_out : STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- Output vectors of the 3 modules
	SIGNAL arith_c, shift_c : STD_LOGIC; -- flag bits coming from AdderSub & Shifter modules (logic module cant logically output carry flag)
	SIGNAL arith_X, arith_Y, shifter_X, shifter_Y, logic_X, logic_Y : STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- X,Y vectors directed to each module
	SIGNAL d : STD_LOGIC; -- signal to shorten the syntax in the V-flag logic
	SIGNAL ALU_almostout : std_logic_vector(n-1 DOWNTO 0); -- used to manipulate the output vector & determine flag bits
	SIGNAL zero_vector : STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- used to compare output to zeroes for Z Flag
BEGIN
------------ PORT MAP INITIATLIZATION ------------
	mapLogic: Logic generic map(n) port map (
		Y => logic_Y, X => logic_X,
		ALUFN_i => ALUFN_i(2 downto 0),
		ALUout_o => logic_out
		);
	mapAdderSub : AdderSub generic map(n) port map(
		Y => arith_Y , X => arith_X,
		ALUFN => ALUFN_i(2 downto 0),
		ALUout => arith_out,
		cout => arith_c
		);
	mapShifter : Shifter generic map(n,k) port map(
		Y => shifter_Y,
		X_to_k => shifter_X(k-1 downto 0),
		ALUFN => ALUFN_i (2 downto 0),
		ALUout_o => shifter_out,
		cout => shift_c
		);

------------ INITIAL OPCODE PROCESSING ------------
--- only the module used recieves the correct X,Y vectors, rest recieve vectors of 0's ---
	 arith_X <= X_i when ALUFN_i(4 DOWNTO 3) = "01" else (others => '0');
	 arith_Y <= Y_i when ALUFN_i(4 DOWNTO 3) = "01" else (others => '0');
	 shifter_X <= X_i when ALUFN_i(4 DOWNTO 3) = "10" else (others => '0');
	 shifter_Y <= Y_i when ALUFN_i(4 DOWNTO 3) = "10" else (others => '0');
	 logic_X <= X_i when ALUFN_i(4 DOWNTO 3) = "11" else (others => '0');
	 logic_Y <= Y_i when ALUFN_i(4 DOWNTO 3) = "11" else (others => '0');

------------ FINAL OUTPUT AND FLAGS ------------
	Cflag_o <= arith_c when ALUFN_i(4 DOWNTO 3) = "01" else
				shift_c when ALUFN_i(4 DOWNTO 3) = "10" else
				'0';
	d <= X_i(n-1) XOR ALUFN_i(0); -- mid-way 'wire' to make the following line shorter		
	Vflag_o <= (NOT Y_i(n-1) AND arith_out(n-1) AND NOT(d)) OR (Y_i(n-1) AND NOT(arith_out(n-1)) AND d) WHEN ALUFN_i(4 DOWNTO 1) = "0100" else '0';
	
	with ALUFN_i(4 DOWNTO 3) select
		ALU_almostout <= arith_out when "01",
						shifter_out when "10",
						logic_out when "11",
						(others => '0') when others;
	
	Nflag_o <= ALU_almostout(n-1); -- MSB of output represents sign
	zero_vector <= (others => '0'); -- create vector of 0's of n size to be compared with output (to find Z-flag status)
	Zflag_o <= '1' when ALU_almostout = zero_vector else '0'; -- checks if output is zeroes
	ALUout_o <= ALU_almostout; -- final output
------------------------------------------------

			 
END struct;

