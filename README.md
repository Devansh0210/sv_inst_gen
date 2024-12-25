# sv_inst_gen
---
This is nvim-treesitter based script to generate template for module instantiation. It comes handy when there are large number of ports and parameters for any module, and it needs to be integrated into toplevel module

## Setup
1. Add [`systemverilog.lua`](https://github.com/Devansh0210/sv_inst_gen/blob/main/systemverilog.lua) file in the following hierarchy of your nvim-config folder
   ```
   ~/.config/nvim/after/ftplugin/systemverilog.lua
   ```
2. Open any sv(Systemverilog/Verilog) file or you can open [`mux2.sv`](https://github.com/Devansh0210/sv_inst_gen/blob/main/test/mux2.sv) in `test/` folder to check the functionality of this script
3. Type `<leader>iv` in `normal` mode and it should show message of instance being copied into clipboard and then you can use `p` command to paste anywhere into your buffer

### Contributing:
- Please feel free to open issue/PR for any suggestions or improvements
