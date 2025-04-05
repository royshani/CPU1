Project Structure and Module Descriptions

1. aux_package.vhd:
   - This package includes declarations for all components and libraries used across the design.
   - It acts as a shared definition space for modular consistency.

2. top.vhd:
   - Serves as the system’s top-level architecture.
   - Accepts three inputs: two n-bit vectors (X and Y) and a 5-bit ALUFN control signal.
   - Based on the upper two bits of ALUFN, the top module selectively enables one of the following submodules:
     • Logic
     • Shifter
     • AdderSub
     The inactive modules receive zeroed inputs to minimize power usage when synthesized.
   - It selects the correct output from the submodules according to ALUFN and computes four status flags:
     • Z (Zero)
     • V (Overflow)
     • C (Carry)
     • N (Negative)

3. Logic.vhd:
   - Performs bitwise logic operations on the X and Y inputs (both n-bit wide).
   - The specific logic operation is determined by the lowest 3 bits of ALUFN.
   - Outputs a result vector of the same size as the inputs.

4. FA.vhd:
   - A Full-Adder component used internally by the AdderSub module.
   - Implements 1-bit addition with carry-in and carry-out.

5. AdderSub.vhd:
   - Handles arithmetic operations based on 2's complement rules.
   - Inputs are n-bit X and Y vectors and the 3 LSBs of ALUFN to select between:
     • Addition
     • Subtraction
     • Bitwise NOT (of X)
     • Inc Y
     • Dec Y
   - Produces an n-bit result and a carry flag.

6. Shifter.vhd:
   - Implements a barrel shifter mechanism for fast shifting.
   - Inputs:
     • Y (n-bit vector to be shifted)
     • X (k-bit value representing the shift amount), set to be 3 LSB's.
     • ALUFN(2:0) to determine the shift operation (e.g., logical, arithmetic, rotate).
   - Outputs the shifted result and a carry-out bit.

