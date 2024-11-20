# HACK@DAC 2021

This directory contains the design from the [HACK@DAC 2021 repo](https://github.com/HACK-EVENT/hackatdac21) snapshotted at commit bcae7aba7f9daee8ad2cfd47b997ac7ad6611034.

The properties.md table contains the properties we wrote for 17 of the 99 known bugs in the design, along with their associated bug descriptions and CWE-ID. The bug numbers and bug descriptions come from the [HACK@DAC 2021 repo](https://github.com/HACK-EVENT/hackatdac21). In some cases, existing CWE entries pointed to one of these 17 known bugs, and we use that CWE-ID. Otherwise, we matched CWEs to bugs using our understanding of the bug and our reading of the CWE descriptions.

# Instructions to load the design in JG

1. Concatenate the setuphack_21.tcl and properties.tcl files into a single file using the following command:

```
cat setuphack_21.tcl properties.tcl > setup_and_properties.tcl
```

2. Modifications for riscv_peripherals and dmi_jtag modules

   - Modify the `riscv_peripherals` module by commenting out the instantiation of the `axi2mem` modules (lines **397-412** and **492-514**) and the `acct_wrapper` module (lines **1719–1735**.), located in the file:

   `verification-benchmarks/hackatdac21/design/hackatdac21/piton/design/chip/tile/ariane/openpiton/riscv_peripherals.sv`.

   - Modify the `dmi_jtag` module, located in the file:

   `verification-benchmarks/hackatdac21/design/hackatdac21/piton/design/chip/tile/ariane/src/riscv-dbg/src/dmi_jtag.sv`

   - Modify **line 25** to specify `NUM_TILES` as `25`:

   ```systemverilog
     input logic [25*2-1:0]      priv_lvl_i,
   ```
