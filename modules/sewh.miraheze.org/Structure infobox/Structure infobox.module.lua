local p = {}
local getArgs = require("Module:Arguments").getArgs
local evilInfobox = require("Module:Evil infobox")

function p.main(frame)
	local args = getArgs(frame)
	local infobox = evilInfobox.new()
	
	infobox:add("title", {
		"{{PAGENAME}}"
	})
	
	infobox:add("image", {
		image1 = {
            file = "Unknown.png",
            width = 128
        }
	})
	
	return infobox:tostring()
end

return p