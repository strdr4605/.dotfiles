local status_ok, delaytrain = pcall(require, "delaytrain")
if not status_ok then
  return
end

delaytrain.setup({
  grace_period = 3, -- How many repeated keypresses are allowed
})
