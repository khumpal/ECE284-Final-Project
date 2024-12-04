# Readme for Alphas
## Alpha 1: Unstructured Pruning (Gating) - Hardware
### Within mac_tile.v

Features:
- The hardware gates conserve power by maintaining the current state when the input is zero.
- We eliminate redundant weights, allowing the hardware to bypass computations associated with these pruned elements.
- `in_w_zero` and `in_n_zero` signals are from `corelet.v` hardware that determines if the input is zero, there will be a signal sent to mux gate to keep the current status. So no change in signal going to the multiplication gate.


## Alpha2: Timeskip structured pruning + QAT (weight stationary and output stationary) - Software
- prune_util.py in the "code" folder can be placed in the "models" folder in the original ece284fa24 github. 
- float_os_prune means floating point model, output stationary, pruned. 
- The overall process for each WS and OS version is, get full precision model trained, iteratively prune it (prune -> train -> prune -> train ...), and then do QAT on the pruned model. 

## Alpha3: Huffman - Software,Hardware

### HUffman decoding has three hardware blocks

- Parallel-to-serial block takes the 32 bit chunks of information from the RAM and produces serial bit stream for the decoding.
- ParallelToSerial.v
- ParallelToSerial_tb.v

### HUffman Decoder

The decoder has the combinational circuits that determine the decoding. We have a counter based decoder that counts the number of zeros in the bit stream to determine the value to be decoded. An LUT in placed for it to be made capable of decoding unique encoding patterns but for our set encoding, the LUT is actually not required.
- huffman_decoder.v
- huffman_decoder_tb.v

### Concatenate Inputs

- Hardware block waits for 4 decodings to concantenate them and send them out as a 32 bit number to be written into the LO cache.

- The complete_decoder.v file brings all three blocks together and it's test bench takes .txt files to test it out. additional files test_front.v and test_front_tb.v test just the first two without the concatenation to test the decoding.

