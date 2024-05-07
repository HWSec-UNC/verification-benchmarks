module plic_regs (
  input logic [2:0][2:0] prio_i,
  output logic [2:0][2:0] prio_o,
  output logic [2:0] prio_we_o,
  output logic [2:0] prio_re_o,
  input logic [0:0][2:0] ip_i,
  output logic [0:0] ip_re_o,
  input logic [3:0][2:0] ie_i,
  output logic [3:0][2:0] ie_o,
  output logic [3:0] ie_we_o,
  output logic [3:0] ie_re_o,
  input logic [3:0][2:0] threshold_i,
  output logic [3:0][2:0] threshold_o,
  output logic [3:0] threshold_we_o,
  output logic [3:0] threshold_re_o,
  input logic [3:0][1:0] cc_i,
  output logic [3:0][1:0] cc_o,
  output logic [3:0] cc_we_o,
  output logic [3:0] cc_re_o,
  // Bus Interface
  input  reg_intf::reg_intf_req_a32_d32 req_i,
  output reg_intf::reg_intf_resp_d32    resp_o
);
always_comb begin
  resp_o.ready = 1'b1;
  resp_o.rdata = '0;
  resp_o.error = '0;
  prio_o = '0;
  prio_we_o = '0;
  prio_re_o = '0;
  ie_o = '0;
  ie_we_o = '0;
  ie_re_o = '0;
  threshold_o = '0;
  threshold_we_o = '0;
  threshold_re_o = '0;
  cc_o = '0;
  cc_we_o = '0;
  cc_re_o = '0;
  if (req_i.valid) begin
    if (req_i.write) begin
      unique case(req_i.addr)
        32'hc000000: begin
          prio_o[0][2:0] = req_i.wdata[2:0];
          prio_we_o[0] = 1'b1;
        end
        32'hc000004: begin
          prio_o[1][2:0] = req_i.wdata[2:0];
          prio_we_o[1] = 1'b1;
        end
        32'hc000008: begin
          prio_o[2][2:0] = req_i.wdata[2:0];
          prio_we_o[2] = 1'b1;
        end
        32'hc002000: begin
          ie_o[0][2:0] = req_i.wdata[2:0];
          ie_we_o[0] = 1'b1;
        end
        32'hc002080: begin
          ie_o[1][2:0] = req_i.wdata[2:0];
          ie_we_o[1] = 1'b1;
        end
        32'hc002100: begin
          ie_o[2][2:0] = req_i.wdata[2:0];
          ie_we_o[2] = 1'b1;
        end
        32'hc002180: begin
          ie_o[3][2:0] = req_i.wdata[2:0];
          ie_we_o[3] = 1'b1;
        end
        32'hc200000: begin
          threshold_o[0][2:0] = req_i.wdata[2:0];
          threshold_we_o[0] = 1'b1;
        end
        32'hc201000: begin
          threshold_o[1][2:0] = req_i.wdata[2:0];
          threshold_we_o[1] = 1'b1;
        end
        32'hc202000: begin
          threshold_o[2][2:0] = req_i.wdata[2:0];
          threshold_we_o[2] = 1'b1;
        end
        32'hc203000: begin
          threshold_o[3][2:0] = req_i.wdata[2:0];
          threshold_we_o[3] = 1'b1;
        end
        32'hc200004: begin
          cc_o[0][1:0] = req_i.wdata[1:0];
          cc_we_o[0] = 1'b1;
        end
        32'hc201004: begin
          cc_o[1][1:0] = req_i.wdata[1:0];
          cc_we_o[1] = 1'b1;
        end
        32'hc202004: begin
          cc_o[2][1:0] = req_i.wdata[1:0];
          cc_we_o[2] = 1'b1;
        end
        32'hc203004: begin
          cc_o[3][1:0] = req_i.wdata[1:0];
          cc_we_o[3] = 1'b1;
        end
        default: resp_o.error = 1'b1;
      endcase
    end else begin
      unique case(req_i.addr)
        32'hc000000: begin
          resp_o.rdata[2:0] = prio_i[0][2:0];
          prio_re_o[0] = 1'b1;
        end
        32'hc000004: begin
          resp_o.rdata[2:0] = prio_i[1][2:0];
          prio_re_o[1] = 1'b1;
        end
        32'hc000008: begin
          resp_o.rdata[2:0] = prio_i[2][2:0];
          prio_re_o[2] = 1'b1;
        end
        32'hc001000: begin
          resp_o.rdata[2:0] = ip_i[0][2:0];
          ip_re_o[0] = 1'b1;
        end
        32'hc002000: begin
          resp_o.rdata[2:0] = ie_i[0][2:0];
          ie_re_o[0] = 1'b1;
        end
        32'hc002080: begin
          resp_o.rdata[2:0] = ie_i[1][2:0];
          ie_re_o[1] = 1'b1;
        end
        32'hc002100: begin
          resp_o.rdata[2:0] = ie_i[2][2:0];
          ie_re_o[2] = 1'b1;
        end
        32'hc002180: begin
          resp_o.rdata[2:0] = ie_i[3][2:0];
          ie_re_o[3] = 1'b1;
        end
        32'hc200000: begin
          resp_o.rdata[2:0] = threshold_i[0][2:0];
          threshold_re_o[0] = 1'b1;
        end
        32'hc201000: begin
          resp_o.rdata[2:0] = threshold_i[1][2:0];
          threshold_re_o[1] = 1'b1;
        end
        32'hc202000: begin
          resp_o.rdata[2:0] = threshold_i[2][2:0];
          threshold_re_o[2] = 1'b1;
        end
        32'hc203000: begin
          resp_o.rdata[2:0] = threshold_i[3][2:0];
          threshold_re_o[3] = 1'b1;
        end
        32'hc200004: begin
          resp_o.rdata[1:0] = cc_i[0][1:0];
          cc_re_o[0] = 1'b1;
        end
        32'hc201004: begin
          resp_o.rdata[1:0] = cc_i[1][1:0];
          cc_re_o[1] = 1'b1;
        end
        32'hc202004: begin
          resp_o.rdata[1:0] = cc_i[2][1:0];
          cc_re_o[2] = 1'b1;
        end
        32'hc203004: begin
          resp_o.rdata[1:0] = cc_i[3][1:0];
          cc_re_o[3] = 1'b1;
        end
        default: resp_o.error = 1'b1;
      endcase
    end
  end
end
endmodule

