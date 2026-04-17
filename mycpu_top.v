module mycpu_top(
    input         clk,
    input         resetn,
    // inst sram interface
    output        inst_sram_en,
    output [ 3:0] inst_sram_wen,
    output [31:0] inst_sram_addr,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    // data sram interface
    output        data_sram_en,
    output [ 3:0] data_sram_wen,
    output [31:0] data_sram_addr,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,
    // trace debug interface
    output [31:0] debug_wb_pc,
    output [ 3:0] debug_wb_rf_we,
    output [ 4:0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);
reg         reset;
always @(posedge clk) reset <= ~resetn;

wire         ds_allowin;
wire         es_allowin;
wire         ms_allowin;
wire         ws_allowin;
wire         fs_to_ds_valid;
wire         ds_to_es_valid;
wire         es_to_ms_valid;
wire         ms_to_ws_valid;
wire [`FS_TO_DS_BUS_WD -1:0] fs_to_ds_bus;
wire [`DS_TO_ES_BUS_WD -1:0] ds_to_es_bus;
wire [`ES_TO_MS_BUS_WD -1:0] es_to_ms_bus;
wire [`MS_TO_WS_BUS_WD -1:0] ms_to_ws_bus;
wire [`WS_TO_RF_BUS_WD -1:0] ws_to_rf_bus;
wire [`BR_BUS_WD       -1:0] br_bus;

wire        es_valid_o;
wire        es_gr_we_o;
wire [4:0]  es_dest_o;
wire        ms_valid_o;
wire        ms_gr_we_o;
wire [4:0]  ms_dest_o;
wire        ws_valid_o;
wire        ws_gr_we_o;
wire [4:0]  ws_dest_o;

// IF stage
if_stage if_stage(
    .clk            (clk            ),
    .reset          (reset          ),
    .ds_allowin     (ds_allowin     ),
    .br_bus         (br_bus         ),
    .fs_to_ds_valid (fs_to_ds_valid ),
    .fs_to_ds_bus   (fs_to_ds_bus   ),
    .inst_sram_en   (inst_sram_en   ),
    .inst_sram_wen  (inst_sram_wen  ),
    .inst_sram_addr (inst_sram_addr ),
    .inst_sram_wdata(inst_sram_wdata),
    .inst_sram_rdata(inst_sram_rdata)
);

// ID stage
id_stage id_stage(
    .clk            (clk            ),
    .reset          (reset          ),
    .es_allowin     (es_allowin     ),
    .ds_allowin     (ds_allowin     ),
    .fs_to_ds_valid (fs_to_ds_valid ),
    .fs_to_ds_bus   (fs_to_ds_bus   ),
    .ds_to_es_valid (ds_to_es_valid ),
    .ds_to_es_bus   (ds_to_es_bus   ),
    .br_bus         (br_bus         ),
    .ws_to_rf_bus   (ws_to_rf_bus   ),
    .es_valid_o     (es_valid_o     ),
    .es_gr_we_o     (es_gr_we_o     ),
    .es_dest_o      (es_dest_o      ),
    .ms_valid_o     (ms_valid_o     ),
    .ms_gr_we_o     (ms_gr_we_o     ),
    .ms_dest_o      (ms_dest_o      ),
    .ws_valid_o     (ws_valid_o     ),
    .ws_gr_we_o     (ws_gr_we_o     ),
    .ws_dest_o      (ws_dest_o      )
);

// EXE stage
exe_stage exe_stage(
    .clk            (clk            ),
    .reset          (reset          ),
    .ms_allowin     (ms_allowin     ),
    .es_allowin     (es_allowin     ),
    .ds_to_es_valid (ds_to_es_valid ),
    .ds_to_es_bus   (ds_to_es_bus   ),
    .es_to_ms_valid (es_to_ms_valid ),
    .es_to_ms_bus   (es_to_ms_bus   ),
    .es_valid_o     (es_valid_o     ),
    .es_gr_we_o     (es_gr_we_o     ),
    .es_dest_o      (es_dest_o      ),
    .data_sram_en   (data_sram_en   ),
    .data_sram_wen  (data_sram_wen  ),
    .data_sram_addr (data_sram_addr ),
    .data_sram_wdata(data_sram_wdata)
);

// MEM stage
mem_stage mem_stage(
    .clk            (clk            ),
    .reset          (reset          ),
    .ws_allowin     (ws_allowin     ),
    .ms_allowin     (ms_allowin     ),
    .es_to_ms_valid (es_to_ms_valid ),
    .es_to_ms_bus   (es_to_ms_bus   ),
    .ms_to_ws_valid (ms_to_ws_valid ),
    .ms_to_ws_bus   (ms_to_ws_bus   ),
    .ms_valid_o     (ms_valid_o     ),
    .ms_gr_we_o     (ms_gr_we_o     ),
    .ms_dest_o      (ms_dest_o      ),
    .data_sram_rdata(data_sram_rdata)
);

// WB stage
wb_stage wb_stage(
    .clk              (clk              ),
    .reset            (reset            ),
    .ws_allowin       (ws_allowin       ),
    .ms_to_ws_valid   (ms_to_ws_valid   ),
    .ms_to_ws_bus     (ms_to_ws_bus     ),
    .ws_to_rf_bus     (ws_to_rf_bus     ),
    .ws_valid_o       (ws_valid_o       ),
    .ws_gr_we_o       (ws_gr_we_o       ),
    .ws_dest_o        (ws_dest_o        ),
    .debug_wb_pc      (debug_wb_pc      ),
    .debug_wb_rf_we   (debug_wb_rf_we   ),
    .debug_wb_rf_wnum (debug_wb_rf_wnum ),
    .debug_wb_rf_wdata(debug_wb_rf_wdata)
);

endmodule
