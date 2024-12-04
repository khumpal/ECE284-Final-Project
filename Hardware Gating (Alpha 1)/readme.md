# Alpha 1: Unstructured Pruning (Gating) - Hardware
## mac_tile.v

Features:
- The hardware gates conserve power by maintaining the current state when the input is zero.
- We eliminate redundant weights, allowing the hardware to bypass computations associated with these pruned elements.
- `in_w_zero` and `in_n_zero` signals are from `corelet.v` hardware that determines if the input is zero, there will be a signal sent to mux gate to keep the current status. So no change in signal going to the multiplication gate.
