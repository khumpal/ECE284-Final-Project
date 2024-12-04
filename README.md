Alpha1 Hardware Gating: 

Alpha2 Timeskip: Timeskip structured pruning + QAT (weight stationary and output stationary). 
- prune_util.py in the "code" folder can be placed in the "models" folder in the original ece284fa24 github. 
- float_os_prune means floating point model, output stationary, pruned. 
- The overall process for each WS and OS version is, get full precision model trained, iteratively prune it (prune -> train -> prune -> train ...), and then do QAT on the pruned model. 

Alpha3 Huffman: (description)
