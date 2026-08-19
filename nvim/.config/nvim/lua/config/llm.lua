local M = {}

local function has_env(name)
  local value = vim.env[name]
  return value ~= nil and value ~= ""
end

local function executable(name)
  return vim.fn.executable(name) == 1
end

function M.detect_adapter()
  if has_env("NVIM_LLM_ADAPTER") then
    return vim.env.NVIM_LLM_ADAPTER
  end

  local providers = {
    { env = "OPENAI_API_KEY", adapter = "openai_responses" },
    { env = "ANTHROPIC_API_KEY", adapter = "anthropic" },
    { env = "GEMINI_API_KEY", adapter = "gemini" },
    { env = "OPENROUTER_API_KEY", adapter = "openrouter" },
    { env = "DEEPSEEK_API_KEY", adapter = "deepseek" },
    { env = "XAI_API_KEY", adapter = "xai" },
    { command = "codex-acp", adapter = "codex" },
    { command = "claude-code-acp", adapter = "claude_code" },
    { command = "gemini", adapter = "gemini_cli" },
    { command = "copilot", adapter = "copilot_acp" },
    { command = "opencode", adapter = "opencode" },
    { command = "ollama", adapter = "ollama" },
  }

  for _, provider in ipairs(providers) do
    if (provider.env and has_env(provider.env)) or (provider.command and executable(provider.command)) then
      return provider.adapter
    end
  end
end

function M.available()
  return M.detect_adapter() ~= nil
end

function M.opts()
  local adapter = M.detect_adapter()
  local model = has_env("NVIM_LLM_MODEL") and vim.env.NVIM_LLM_MODEL or nil

  if adapter == "ollama" and model == nil then
    model = "qwen2.5-coder:7b"
  end

  local interaction_adapter = model and { name = adapter, model = model } or adapter

  return {
    interactions = {
      chat = { adapter = interaction_adapter },
      inline = { adapter = interaction_adapter },
      cmd = { adapter = interaction_adapter },
    },
  }
end

return M
