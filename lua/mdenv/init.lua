local mdenv = {}

mdenv.setup = function(opts)
  require('mdenv.config').set(opts)
end

return mdenv
