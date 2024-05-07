# OR1200
This directory contains a buggy version of the OR1200 processor. The inserted bugs have been collected by prior work in the security verification space, described below.

Properties.md contains the complete list of SystemVerilog security properties for this design. For each property, we include the CWE-ID and categorize it into one of 5 buckets: control flow, privilege escalation/de-escalation, correct update to registers, memory access and correct computation of results. We also provide the results we get when verifying these properties with JasperGold FPV.
