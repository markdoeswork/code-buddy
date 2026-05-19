-- Makes HTTP requests to the DeepInfra OpenAI-compatible API.
-- Uses curl via vim.system (non-blocking).

local M        = {}

local ENDPOINT = "https://api.deepinfra.com/v1/openai/chat/completions"
local API_KEY  = "VJx0qtJ0Cm9bH09vtHZx3OqIEL3H0Kjr"
-- local MODEL    = "moonshotai/Kimi-K2.6"
local MODEL    = "Qwen/Qwen3.6-35B-A3B"

M.MODEL        = MODEL -- exposed for tombstone metadata

-- callback(ok, text)
--   ok   = true  → text is the assistant reply string
--   ok   = false → text is an error message
function M.chat(prompt, callback)
  local body = vim.fn.json_encode({
    model = MODEL,
    messages = { { role = "user", content = prompt } },
    chat_template_kwargs = { enable_thinking = false },
  })

  vim.system(
    {
      "curl", "-s", "-X", "POST", ENDPOINT,
      "-H", "Content-Type: application/json",
      "-H", "Authorization: Bearer " .. API_KEY,
      "-d", body,
    },
    { text = true },
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          callback(false, "curl error: " .. (result.stderr or "unknown"))
          return
        end

        local ok, decoded = pcall(vim.fn.json_decode, result.stdout)
        if not ok or type(decoded) ~= "table" then
          callback(false, "json decode error: " .. result.stdout)
          return
        end

        local choices = decoded.choices
        if not choices or not choices[1] then
          callback(false, "no choices in response")
          return
        end

        local text = choices[1].message and choices[1].message.content or ""
        callback(true, text)
      end)
    end
  )
end

return M
