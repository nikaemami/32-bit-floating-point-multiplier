# 32-bit-floating-point-multiplier
Design and implementation of a 32-bit floating-point multiplier that uses the IEEE 754-2019 Floating-Point standard, in a hierarchical fashion.

A 32-bit signed multiplier (32-bit FP A and B inputs and producing a 32-bit result) is designed. The inputs are taken from the 32-bit input bus inBus in two 2-line responsive handshaking processes, and the output is to be placed on the 32-bit outBus. For the inputs a 2- line fully-responsive handshaking is used for making the data available on inBus. The external inReady becomes 1 when and inputs is ready and stays 1 until our circuit issues inAccept. This is followed by another round of handshaking for the second input. When result is ready, our circuit issues resultReady and waits for the device reading the output to issue resultAccepted.

The main floating-point (FP) multiplier has a startFP and a doneFP output. When its two inputs are ready, a positive pulse of startFP starts the FP process. When this is done, the doneFP is asserted and stays asserted for as long as a new set if data has not started.
The circuit has a wrapper that handles the external handshaking as discussed above and delivers it to the FP multiplier. The same wrapper also handles the output handshaking.

The circuit uses a sequential multiplier and a combinational adder for its internal processing. The sequential multiplier starts with a positive pulse on startMul. When received, the circuit accepts both its inputs and performs an unsigned multiplication. The multiplication result becomes available on the sequential shift-and-add multiplier’s 24-bit output and a doneMul is issued.


