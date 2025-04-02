LIBRARY ieee;  -- Import IEEE standard library for VHDL.
USE ieee.std_logic_1164.all;  -- Use standard logic types and operations.

-------------------------------------

entity AdderSub is
    generic (n: INTEGER := 8);  -- Define a generic value for bit-width (default is 8).
    port (
        X, Y : IN std_logic_vector (n-1 downto 0);  -- Input operands X and Y.
        ALUFN : IN std_logic_vector (2 downto 0);  -- ALU function select (3-bit opcode).
        ALUout : OUT std_logic_vector(n-1 downto 0);  -- Output result of ALU operation.
        cout : OUT std_logic  -- Carry-out signal.
    );
end AdderSub;

architecture AdderSubArch of AdderSub is
    component FA is  -- Full Adder component declaration.
        PORT (
            xi, yi, cin: IN std_logic;  -- Inputs to the full adder.
            s, cout: OUT std_logic  -- Sum and carry-out outputs.
        );
    end component;

    SIGNAL curr_cin : std_logic_vector(n-1 DOWNTO 0);  -- Internal register for carry propagation.
    SIGNAL x_vec, y_vec : std_logic_vector(n-1 DOWNTO 0);  -- Control signals for modified X and Y.
    SIGNAL cin : std_logic;  -- Carry-in for the first full adder.

begin

    -- Determine how X should be processed based on ALU function.
    x_vec <= (others => '0') when (ALUFN = "011") else  -- Increment Y by 1 (X unused).
             (others => '1') when (ALUFN = "100") else  -- Decrement Y by 1 (X unused).
             not X when (ALUFN = "001" or ALUFN = "010") else  -- Subtraction or negation (2's complement).
             X when ALUFN = "000" else  -- Normal addition (X remains unchanged).
             (others => '0');  -- Default case: set to zero.
    
    -- Determine how Y should be processed based on ALU function.
    y_vec <= Y when (ALUFN = "000" or ALUFN = "001" or ALUFN = "011" or ALUFN = "100") else
             (others => '0');  -- Set to zero for negation operation.

    -- Carry-in logic: set to '1' for subtraction, negation, or increment operations.
    cin <= '1' when (ALUFN = "001" or ALUFN = "010" or ALUFN = "011") else '0';

    -- Instantiate the first full adder for the least significant bit.
    MapFirstFA : FA port map (
        xi => x_vec(0),
        yi => y_vec(0),
        cin => cin,  -- Use carry-in for first bit.
        s => ALUout(0),
        cout => curr_cin(0)  -- Carry-out is stored for next stage.
    );

    -- Generate a ripple-carry adder/subtractor using full adders.
    MapRestFA : for i in 1 to n-1 generate
        chain : FA port map (
            xi => x_vec(i),
            yi => y_vec(i),
            cin =>curr_cin(i-1),  -- Carry-in from the previous stage.
            s => ALUout(i),
            cout => curr_cin(i)  -- Carry-out for next stage.
        );
    end generate;

    cout <= curr_cin(n-1);  -- Assign final carry-out to output.

end AdderSubArch;
