# HACK@DAC 2019
This directory contains the design from the [HACK@DAC 2019 repo](https://github.com/HACK-EVENT/hackatdac19) snapshotted at commit 57e7b2109c1ea2451914878df2e6ca740c2dcf34.

The properties.md table contains the properties we wrote for 11 of the 66 known bugs in the design, along with their associated bug descriptions and CWE-ID. The bug numbers and bug descriptions come from the [HACK@DAC 2019 site](https://hackthesilicon.com/dac19-setup/) (scroll to the bottom). In some cases, existing CWE entries pointed to one of these 11 known bugs, and we use that CWE-ID. Otherwise, we matched CWEs to bugs using our understanding of the bug and our reading of the CWE descriptions. 

# Instructions to load the design in JG

1. Concatenate the analyze-hack19.tcl and properties.tcl files into a single file using the following command:

```
cat analyze-hack19.tcl properties.tcl > setup_and_properties.tcl
```

2. Modifications for axi_node_intf_wrap and connectivity_mapping Modules
   * Modify the `axi_node_intf_wrap` module by commenting out the `generate` block located in the file:  
`verification-benchmarks/hackatdac19/design/src/axi_node/src/axi_node_intf_wrap.sv`, lines **152–265**.
   * Update the `connectivity_mapping` module to include wire signals required for property verification in JasperGold (JG). Below is the modified `connectivity_mapping` module code: 
```systemverilog
module connectivity_mapping #(
    parameter NB_MANAGER      = 4,
    parameter NB_SUBORDINATE  = 4,
    parameter NB_PRIV_LVL     = 4,
    parameter PRIV_LVL_WIDTH  = 4
  )(
    input  logic [PRIV_LVL_WIDTH-1:0]                priv_lvl_i,
    input  logic [NB_SUBORDINATE-1:0][NB_MANAGER-1:0][NB_PRIV_LVL-1:0] access_ctrl_i,

    output logic [NB_SUBORDINATE-1:0][NB_MANAGER-1:0] connectivity_map_o
  );

  genvar i,j ;
  wire [NB_SUBORDINATE-1:0] runtime_i;
  wire [NB_MANAGER-1:0] runtime_j;

  generate
    for (i=0; i<NB_SUBORDINATE; i++)
    begin
          assign runtime_i = i;
        for (j=0; j<NB_MANAGER; j++)
        begin
          assign runtime_j = j;
          assign connectivity_map_o[i][j] = access_ctrl_i[i][j][priv_lvl_i] || ((j==6) && access_ctrl_i[i][7][priv_lvl_i]) ;
        end
    end

  endgenerate
endmodule
```
