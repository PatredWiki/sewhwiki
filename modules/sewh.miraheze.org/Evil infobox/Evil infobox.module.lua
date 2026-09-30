-- still a wip

local frm = mw.getCurrentFrame()
local getArgs = require("Module:Arguments").getArgs
local Components = require("Module:Evil infobox/components")
require("Module:Mw.html extension")

-- infobox
local Infobox = {}
Infobox.__index = Infobox

-- create infobox
function Infobox.new(args)
    local obj = setmetatable({
        args = args,
        rows = {}
    }, Infobox)
    return obj
end

-- add a component
function Infobox:add(component, args)
    local component = Components[component](self, args)
    table.insert(self.rows, component)

    return self
end

-- collect image parameters
function Infobox:collectImageParams()
    local meta = {
        __index = function(tbl, key)
            local new = setmetatable({}, meta)
            tbl[key] = new
            return new
        end
    }
    local imageargs = setmetatable({}, meta)

    local validargs_raw = {
        "file", "width", "height", "bgwidth",
        "bgheight", "name", "caption"
    }
    local validargs = {}

    for _,v in pairs(validargs_raw) do
        validargs[v] = true
    end

    for k,v in pairs(self.args) do
        local imageid = k:match("^image%d+")
        if k:match("^image%-") then
            imageid = "image1"
        end
        local arg = k:match("%-%w+$")

        if imageid and arg then
            arg = arg:gsub("^%-", "")
            if validargs[arg] then
                imageargs[imageid][arg] = v
            end
        end
    end

    if not next(imageargs) then
        return false
    end

    return imageargs
end

-- convert to string
function Infobox:tostring()
    local infobox = mw.html.create("table")
        :addClasses {
            "infobox-wrapper",
            "infobox",
            "border--beveled-background"
        }
        :addCss {
            height = "fit-content"
        }

    local styles = frm:extensionTag("templatestyles", "", {src = "Module:Evil infobox/styles.css"})

    for _,row in ipairs(self.rows) do
        infobox:node(row)
    end

    return tostring(infobox) .. tostring(styles)
end

return Infobox