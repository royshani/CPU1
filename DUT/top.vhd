LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;

-------------------------------------
ENTITY top IS
  GENERIC (
    n : INTEGER := 8;
    k : INTEGER := 3;  -- k = log2(n)
    m : INTEGER := 4   -- m = 2^(k-1)
  );
  PORT (
    Y_i, X_i : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    ALUFN_i  : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    ALUout_o : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    Nflag_o, Cflag_o, Zflag_o, Vflag_o : OUT STD_LOGIC  -- N, C, Z, V flags
  );
END top;

-------------------------------------------------------
ARCHITECTURE struct OF top IS 
  -- ALL COMPONENT DECLARATIONS ARE WITHIN AUX_PACKAGE.VHD --

  SIGNAL arith_out, shifter_out, logic_out : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL arith_c, shift_c : STD_LOGIC;  -- Carry flags from relevant modules
  SIGNAL arith_input_X, arith_input_Y : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL shifter_input_X, shifter_input_Y : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL logic_input_X, logic_input_Y : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL d : STD_LOGIC;  -- Helper signal for V-flag logic
  SIGNAL selected_ALU_result : STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- Final selected ALU output
  SIGNAL zero_vector : STD_LOGIC_VECTOR(n-1 DOWNTO 0);  -- For Z flag detection
BEGIN

  ------------ PORT MAP INITIALIZATION ------------
  mapLogic: Logic
    GENERIC MAP(n)
    PORT MAP (
      Y => logic_input_Y,
      X => logic_input_X,
      ALUFN_i => ALUFN_i(2 DOWNTO 0),
      ALUout_o => logic_out
    );

  mapAdderSub: AdderSub
    GENERIC MAP(n)
    PORT MAP (
      Y => arith_input_Y,
      X => arith_input_X,
      ALUFN => ALUFN_i(2 DOWNTO 0),
      ALUout => arith_out,
      cout => arith_c
    );

  mapShifter: Shifter
    GENERIC MAP(n, k)
    PORT MAP (
      Y => shifter_input_Y,
      X_to_k => shifter_input_X(k-1 DOWNTO 0),
      ALUFN => ALUFN_i(2 DOWNTO 0),
      ALUout_o => shifter_out,
      cout => shift_c
    );

  ------------ INITIAL OPCODE PROCESSING ------------
  arith_input_X <= X_i when ALUFN_i(4 DOWNTO 3) = "01" else (others => '0');
  arith_input_Y <= Y_i when ALUFN_i(4 DOWNTO 3) = "01" else (others => '0');

  shifter_input_X <= X_i when ALUFN_i(4 DOWNTO 3) = "10" else (others => '0');
  shifter_input_Y <= Y_i when ALUFN_i(4 DOWNTO 3) = "10" else (others => '0');

  logic_input_X <= X_i when ALUFN_i(4 DOWNTO 3) = "11" else (others => '0');
  logic_input_Y <= Y_i when ALUFN_i(4 DOWNTO 3) = "11" else (others => '0');

  ------------ FINAL OUTPUT AND FLAGS ------------
  Cflag_o <= arith_c when ALUFN_i(4 DOWNTO 3) = "01" else
             shift_c when ALUFN_i(4 DOWNTO 3) = "10" else
             '0';

  d <= X_i(n-1) XOR ALUFN_i(0);  -- Helper wire for V flag logic

  Vflag_o <= (NOT Y_i(n-1) AND arith_out(n-1) AND NOT d) OR
             (Y_i(n-1) AND NOT arith_out(n-1) AND d)
             WHEN ALUFN_i(4 DOWNTO 1) = "0100" ELSE '0';

  WITH ALUFN_i(4 DOWNTO 3) SELECT
    selected_ALU_result <= arith_out    WHEN "01",
                            shifter_out WHEN "10",
                            logic_out   WHEN "11",
                            (others => '0') WHEN OTHERS;

  Nflag_o <= selected_ALU_result(n-1);  -- Sign flag (MSB)
  zero_vector <= (others => '0');
  Zflag_o <= '1' WHEN selected_ALU_result = zero_vector ELSE '0';
  ALUout_o <= selected_ALU_result;

END struct;
