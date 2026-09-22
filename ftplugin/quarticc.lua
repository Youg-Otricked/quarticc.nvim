local ns_id = vim.api.nvim_create_namespace("quarticc_syntax")
local diag_ns_id = vim.api.nvim_create_namespace("quarticc_diagnostics")
local token_map = {
  ["int"]         = "Type",
  ["string"]      = "Type",
  ["addr_t"]      = "Type",
  ["long int"]    = "Type",
  ["short int"]   = "Type",
  ["long double"] = "Type",
  ["float"]       = "Type",
  ["double"]      = "Type",
  ["char"]        = "Type",
  ["bool"]        = "Type",
  ["qbool"]       = "Type",
  ["if"]          = "Conditional",
  ["else"]        = "Conditional",
  ["switch"]      = "Conditional",
  ["case"]        = "Label",
  ["default"]     = "Label",
  ["break"]       = "Keyword",
  ["sizeof"]      = "Keyword",
  ["throw"]       = "Keyword",
  ["identifier"]  = "Identifier",
  ["keyword"]     = "Keyword",
  ["fstring"]     = "String",
  ["+"]           = "Operator",
  ["-"]           = "Operator",
  ["*"]           = "Operator",
  ["/"]           = "Operator",
  ["%"]           = "Operator",
  ["#^"]          = "Operator",
  ["="]           = "Operator",
  ["+="]          = "Operator",
  ["-="]          = "Operator",
  ["*="]          = "Operator",
  ["/="]          = "Operator",
  ["%="]          = "Operator",
  ["++"]          = "Operator",
  ["--"]          = "Operator",
  ["=="]          = "Operator",
  ["!="]          = "Operator",
  [">"]           = "Operator",
  ["<"]           = "Operator",
  [">="]          = "Operator",
  ["<="]          = "Operator",
  ["&&&"]         = "Operator",
  ["||"]          = "Operator",
  ["^"]           = "Operator",
  ["!"]           = "Operator",
  ["|||"]         = "Operator",
  ["^^"]          = "Operator",
  ["!!"]          = "Operator",
  ["==="]         = "Operator",
  ["!=="]         = "Operator",
  ["&|&"]         = "Operator",
  ["|&|"]         = "Operator",
  ["&"]           = "Operator",
  ["::"]          = "Operator",
  ["<<"]          = "Operator",
  ["|>"]          = "Operator",
  ["|>>"]         = "Operator",
  ["<<<"]         = "Operator",
  ["$"]           = "Operator",
  ["~"]           = "Operator",
  [":>"]          = "Operator",
  [":>="]         = "Operator",
  ["|>="]         = "Operator",
  ["|>>="]        = "Operator",
  ["<<="]         = "Operator",
  ["<<<="]        = "Operator",
  ["$="]          = "Operator",
  ["|="]          = "Operator",
  ["&="]          = "Operator",
  ["|"]           = "Operator",
  ["("]           = "Delimiter",
  [")"]           = "Delimiter",
  ["{"]           = "Delimiter",
  ["}"]           = "Delimiter",
  ["["]           = "Delimiter",
  ["]"]           = "Delimiter",
  [","]           = "Delimiter",
  ["."]           = "Delimiter",
  [":"]           = "Delimiter",
  [";"]           = "Delimiter",
  ["->"]          = "Delimiter",
  ["@"]           = "Delimiter",
  ["..."]         = "Delimiter",
}
local hl_timer = nil
local qc_job = nil
local qc_timeout = nil
local run_generation = 0
local function stop_qc_job()
  if qc_timeout then
    qc_timeout:stop()
    qc_timeout:close()
    qc_timeout = nil
  end
  if qc_job then
    vim.fn.jobstop(qc_job)
    qc_job = nil
  end
end
local function run_lexer_highlight()
  local bufnr = vim.api.nvim_get_current_buf()
  stop_qc_job()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local line_map = {}
  do
    local lexer_line = 0
    for buf_line, text in ipairs(lines) do
      if not text:match("^%s*#") then
        line_map[lexer_line] = buf_line - 1
        lexer_line = lexer_line + 1
      end
    end
  end
  local source_path = vim.api.nvim_buf_get_name(bufnr)
  if source_path == "" then
    return
  end
  local source_dir = vim.fs.dirname(source_path)
  local extension = vim.fn.fnamemodify(source_path, ":e")
  local tmp_file = source_dir
      .. "/."
      .. vim.fn.fnamemodify(vim.fn.tempname(), ":t")
      .. "."
      .. extension
  local f = io.open(tmp_file, "w")
  if not f then
    return
  end
  f:write(table.concat(lines, "\n"))
  f:close()
  local stdout_data = {}
  local stderr_data = {}
  run_generation = run_generation + 1
  local generation = run_generation
  local cmd = {
    "qc",
    tmp_file,
    "-dump-tokens",
  }
  qc_job = vim.fn.jobstart(cmd, {
    cwd = source_dir,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if generation ~= run_generation then
        return
      end
      for _, line in ipairs(data or {}) do
        if line ~= "" then
          table.insert(stdout_data, line)
        end
      end
    end,
    on_stderr = function(_, data)
      if generation ~= run_generation then
        return
      end
      for _, line in ipairs(data or {}) do
        if line ~= "" then
          table.insert(stderr_data, line)
        end
      end
    end,
    on_exit = function(job_id, exit_code)
      if generation ~= run_generation then
        os.remove(tmp_file)
        return
      end
      if qc_timeout then
        qc_timeout:stop()
        qc_timeout:close()
        qc_timeout = nil
      end
      if qc_job == job_id then
        qc_job = nil
      end
      os.remove(tmp_file)
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
        vim.diagnostic.reset(diag_ns_id, bufnr)
        local diagnostics = {}
        if exit_code ~= 0 then
          for _, line in ipairs(stderr_data) do
            if line ~= "" then
              vim.notify(
                "qc: " .. line,
                vim.log.levels.ERROR
              )
            end
          end
        end
        for _, line in ipairs(stdout_data) do
          line = line:gsub("\r", "")
          if not line:match("^#")
              and not line:match("<eof>")
              and line ~= ""
              and not line:match("^%-") then
            if line:match("^ERROR:") then
              local l_num, col, len, msg = line:match("^ERROR:%s*(%d+)%s+(%d+)%s+(%d+)%s+(.*)$")
              if l_num then
                local line_num = line_map[tonumber(l_num)]
                if line_num then
                  table.insert(diagnostics, {
                    bufnr = bufnr,
                    lnum = line_num,
                    col = tonumber(col),
                    end_lnum = line_num,
                    end_col = tonumber(col) + tonumber(len),
                    severity = vim.diagnostic.severity.ERROR,
                    message = msg,
                    source = "qc-compiler",
                  })
                end
              end
            else
              local l_num, col, len, token_type = line:match("^(%d+) (%d+) (%d+) (.*)$")
              if l_num then
                local line_num = line_map[tonumber(l_num)]
                if line_num and token_map[token_type] then
                  vim.api.nvim_buf_add_highlight(
                    bufnr,
                    ns_id,
                    token_map[token_type],
                    line_num,
                    tonumber(col),
                    tonumber(col) + tonumber(len)
                  )
                end
              end
            end
          end
        end
        vim.diagnostic.set(
          diag_ns_id,
          bufnr,
          diagnostics
        )
      end)
    end,
  })
  if qc_job <= 0 then
    qc_job = nil
    os.remove(tmp_file)
    return
  end
  qc_timeout = vim.loop.new_timer()
  qc_timeout:start(
    3000,
    0,
    vim.schedule_wrap(function()
      if generation ~= run_generation then
        return
      end
      if qc_job then
        vim.notify(
          "qc timed out after 3 seconds",
          vim.log.levels.ERROR
        )
        stop_qc_job()
        os.remove(tmp_file)
      end
    end)
  )
end
local function debounced_highlight()
  if hl_timer then
    hl_timer:stop()
    hl_timer:close()
    hl_timer = nil
  end
  hl_timer = vim.loop.new_timer()
  hl_timer:start(
    250,
    0,
    vim.schedule_wrap(function()
      run_lexer_highlight()

      if hl_timer then
        hl_timer:close()
        hl_timer = nil
      end
    end)
  )
end
vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "TextChangedP" }, {
  buffer = vim.api.nvim_get_current_buf(),
  callback = debounced_highlight,
})
