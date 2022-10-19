local noice_status_ok, noice = pcall(require, "noice")
if not noice_status_ok then
  return
end
noice.setup()
