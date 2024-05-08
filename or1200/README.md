# OR1200
This directory contains a buggy version of the OR1200 processor. The inserted bugs have been collected by prior work in the security verification space \[[1]\] \[[2]\].

Properties.md contains the complete list of SystemVerilog security properties for this design. For each property, we classify it in two ways: first by providing the appropriate CWE ID, and second by categorizing it using the 5 buckets of that same prior work (control flow, privilege escalation/de-escalation, correct update to registers, memory access and correct computation of results). For each property we also report our results when verifying the property with Cadence JasperGold FPV. We ensure that the design in the directory compiles for JasperGold as is. 

[1]:https://dl.acm.org/doi/10.1145/2775054.2694366
[2]:https://dl.acm.org/doi/10.1145/3037697.3037734
