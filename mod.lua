function data()
return {
	info = {
		minorVersion = 0,
		severityAdd = "NONE",
		severityRemove = "NONE",
		name = _("name"),
		description = _("desc"),
    authors = {
      {
        name = "Klamann",
        role = "CREATOR",
        text = "",
        steamProfile = "Klamann",
        tfnetId = 21474,
      },
    },
    tags = { "Train Station", "Freight Station", "Script Mod" },
	},
	runFn = function (settings)
		local stationmod = require "stationmod"
	end
}
end
