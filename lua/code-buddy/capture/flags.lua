-- All supported --buddy flags.
-- Each key is the flag name (matches what's parsed from the marker line).
-- The description is for documentation only.
local M = {}

M.flags = {
  function_ = { name = "function", description = "Include the full enclosing function source in the output" },
  ai        = { name = "ai",       description = "Send the context + question to the AI and inject the reply" },
  replace   = { name = "replace",  description = "Replace the function in the buffer with the AI's updated version" },
}

return M
