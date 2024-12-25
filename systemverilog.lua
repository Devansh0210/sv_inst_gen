-- local logger = require("harpoon.logger")

function Ps(...)
    local objects = vim.tbl_map(vim.inspect, { ... }) or {1}
    if type(objects) == string then
        return objects
    else 
        return string.format("%s", unpack(objects))
    end
end

function P(...)
    local objects = vim.tbl_map(vim.inspect, { ... })
    print(unpack(objects))
end

function find_node_ancestor(types, node)
  if not node then
    return nil
  end

  if vim.tbl_contains(types, node:type()) then
    return node
  end

  local parent = node:parent()

  return find_node_ancestor(types, parent)
end

vim.keymap.set("n", "<leader>iv", (function() 
    local cur_node = vim.treesitter.get_node({ignore_injections=false})
    local tree = cur_node:tree();
    local mod_node = nil;

    local mod_query = vim.treesitter.query.parse(
    'verilog',
    string.format(
        [[
        (module_declaration
            (module_ansi_header 
            (module_keyword) 
            name: (simple_identifier) @mod_name))
        ]]
    ))

    local module_name = "default"
    for _, _match, _ in mod_query:iter_matches(tree:root(), 0) do
        for id, node in pairs(_match) do 
            local name = mod_query.captures[id]
            if name == 'mod_name' then 
                module_name = (vim.treesitter.get_node_text(node, 0))
                mod_node = node
            end
        end
    end

    if (mod_node == nil) then
        print("No modules found")
        return
    end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local lang_tree = vim.treesitter.get_parser(0):language_for_range ({ cursor[1], cursor[2], cursor[1], cursor[2]})

    local param_dict = {}

    local query = vim.treesitter.query.parse(
    'verilog',
    string.format(
        [[
        (parameter_port_list 
            (parameter_port_declaration 
                (parameter_declaration
                    (list_of_param_assignments
                        (param_assignment (simple_identifier) @param_name
                        (constant_param_expression) @const_val (#vim-match? @const_val "^[0-9]*[']?[dbho]?[0-9]+$"))* @param_key))))
        ]]
    ))

    local ii = 1
    local longest_param_name_length = 0
    local tab_val = vim.o.tabstop;
    local tab_str = string.rep(" ", tab_val)
    local tab_str = "    "

    for _, _match, _ in query:iter_matches(tree:root(), 0) do
        local elem = {name= "default", val= "default"}
        for id, node in pairs(_match) do 
            local name = query.captures[id]
            if name == 'param_name' then 
                elem.name = (vim.treesitter.get_node_text(node, 0))
            end
            if name == 'const_val' then 
                elem.val = (vim.treesitter.get_node_text(node, 0))
            end

        end

        if #elem.name > longest_param_name_length then
            longest_param_name_length = #elem.name
        end
        table.insert(param_dict, ii, elem)
        ii = ii + 1
    end


    local port_query = vim.treesitter.query.parse(
    'verilog',
    string.format(
        [[
        (list_of_port_declarations  
            (ansi_port_declaration 
                (net_port_header)?
                port_name: (simple_identifier) @net_name))?
        (list_of_ports
            (port (simple_identifier) @net_name))?
        ]]
    ))

    local port_nets = {}
    local longest_port_name_length = 0
    for _, _match, _ in port_query:iter_matches(tree:root(), 0) do
        local port = nil 
        for id, node in pairs(_match) do 
            local name = port_query.captures[id]
            if name == 'net_name' then 
                port = vim.treesitter.get_node_text(node, 0)
            end
        end

        if (port ~= nil) then
            if (longest_port_name_length < #port) then
                longest_port_name_length = #port
            end
            table.insert(port_nets, port)
        end
    end


    local v_writer = tab_str .. string.format("%s #(\n", module_name) 
    for ii, elem in pairs(param_dict) do
        if (ii == #param_dict) then
            v_writer = v_writer .. string.rep(tab_str, 2) .. string.format(".%s", elem.name) .. string.rep(" ", longest_param_name_length - #elem.name) .. string.format("(%s)\n", elem.val)
        else 
            v_writer = v_writer .. string.rep(tab_str, 2) .. string.format(".%s", elem.name) .. string.rep(" ", longest_param_name_length - #elem.name) .. string.format("(%s),\n", elem.val)
        end
    end

    v_writer = v_writer .. tab_str .. string.format(") u_%s (\n", module_name)

    for ii, elem in pairs(port_nets) do 
        if (ii == #port_nets) then
            v_writer = v_writer .. string.rep(tab_str, 2) .. string.format(".%s", elem) .. string.rep(" ", longest_port_name_length - #elem) .. string.format("(%s)\n", elem)
        else 
            v_writer = v_writer .. string.rep(tab_str, 2) .. string.format(".%s", elem) .. string.rep(" ", longest_port_name_length - #elem) .. string.format("(%s),\n", elem)
        end
    end

    v_writer = v_writer .. tab_str .. ");\n"
    vim.fn.setreg('"*', v_writer)
    print(string.format("Instance template for %s module is copied into clipboard", module_name))
end))
