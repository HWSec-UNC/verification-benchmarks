# HACK@DAC 2018
This directory contains the design from the [HACK@DAC 2018 repo](https://github.com/HACK-EVENT/hackatdac18) snapshotted at commit 60534635d40f397d71b45be511d954af2c0c7b3d. 

The properties.md table contains the properties we wrote for 20 of the 31 known bugs in the design, along with their associated bug descriptions and CWE-ID. The bug numbers and bug descriptions come from the [HACK@DAC 2018 repo](https://github.com/HACK-EVENT/hackatdac18). In some cases, existing CWE entries pointed to one of these 20 known bugs, and we use that CWE-ID. Otherwise, we matched CWEs to bugs using our understanding of the bug and our reading of the CWE descriptions. 

# Instructions to load the design in JG

1. Concatenate the run_analysis.tcl and properties.tcl files into a single file using the following command:

```
cat run_analysis.tcl properties.tcl > setup_and_properties.tcl
```
2. Modifications for the riscv_core Module
   * Modify the `riscv_core.sv` module by commenting out the `riscv_tracer` instantiation located in the file:  
`verification-benchmarks/hackatdac18/ips/riscv/riscv_core.sv`, lines **1089–1153**.