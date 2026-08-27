-- still a wip

local p = {}
local frm = mw.getCurrentFrame()
local getArgs = require("Module:Arguments").getArgs
require("Module:Mw.html extension")

-- helper functions
local function error(message)
    local error = mw.html.create("strong")
        :addClass("error")
        :wikitext(message)

    return error
end

local function is(val, expected)
    return type(val) == expected
end

local function remove(str, pattern)
    if not is(str, "string") then return str
    return str:gsub(pattern, "")
end


-- components
local Components = {}

function Components.row(infobox, args)
    local row = mw.html.create("tr")
        :addClass("infobox-row")
        :tr()
            :th {
                args[1] or "No heading..."
            }
            :td {
                args[2] or "No data..."
            }
            :allDone()
        :addClasses(args.class)
        :addCss(args.css)

    return row
end

function Components.title(infobox, args)
    local title = mw.html.create("tr")
        :addClass("infobox-title")
        :tr()
            :th {
                args[1] or "No title...",
                attr = {colspan = 2},
                css = {
                    ["-webkit-text-stroke"] = "4px black",
                    ["paint-order"] = "stroke fill"
                }
            }
            :allDone()
        :addClasses(args.class)
        :addCss(args.css)

    return title
end

function Components.subtitle(infobox, args)
    local subtitle = mw.html.create("tr")
        :addClass("infobox-subtitle")
        :tr()
            :th {
                args[1] or "No subtitle...",
                attr = {colspan = 2},
                css = {
                    ["-webkit-text-stroke"] = "4px black",
                    ["paint-order"] = "stroke fill"
                }
            }
            :allDone()
        :addClasses(args.class)
        :addCss(args.css)

    return subtitle
end

function Components.header(infobox, args)
    local header = mw.html.create("tr")
        :addClass("infobox-header")
        :tr()
            :th {
                args[1] or "No heading...",
                attr = {colspan = 2},
                css = {
                    ["-webkit-text-stroke"] = "4px black",
                    ["paint-order"] = "stroke fill"
                }
            }
            :allDone()
        :addClasses(args.class)
        :addCss(args.css)

    return header
end

function Components.textarea(infobox, args)
    local textarea = mw.html.create("tr")
        :addClass("infobox-textarea")
        :tr()
            :td {
                args[1] or "No text here...",
                attr = {colspan = 2}
            }
            :addClasses(args.class)
            :addCss(args.css)
            :allDone()

    return textarea
end

function Components.currency(infobox, args)
    local template = frm:expandTemplate{
        title = "Currency",
        args = {
            args.currency or "Dosh",
            args.price or "?",
            "n"
        }
    }

    local currency = mw.html.create("tr")
        :addClass("infobox-currency")
        :tr()
            :td {
                template,
                attr = {colspan = 2}
            }
            :addClasses(args.class)
            :addCss(args.css)
            :allDone()

    return currency
end

function Components.image(infobox, args)
    local images = {}

    for k,v in pairs(args) do
        if k:matcH("^image%d+$") then
            local id = tonumber(k:match("%d+"))
            images[id] = v
        end
    end

    if #images < 1 then
        error("You need at least one image boi")
    elseif #images == 1 then
    elseif #images > 1 then
        tabberargs = {}

        for k,v in ipairs(images) do
            local image = ("[[File:%s|%spx]]"):format(
                remove(v.image, "File:"),
                (v.width and remove(v.width, "px") or 100) ..
                (v.height and "x" .. remove(v.height, "px") or "")
            )

            tabberargs["tab" .. k] = v.name or "Image " .. k
            tabberargs["content" .. k] = image
        end

        frm:expandTemplate{
            title = "Tabber",
            args = tabberargs
        }
    end
end

-- infobox
local Infobox = {}
Infobox.__index = Infobox

-- create infobox
function Infobox.new(args)
    local obj = setmetatable({
        rawargs = args,
        args = {},
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

-- convert to string
function Infobox:tostring()
    local infobox = mw.html.create("table")
        :addClasses{
            "infobox-wrapper",
            "infobox",
            "border--beveled-background"
        }
        :addCss{
            height = "fit-content"
        }

    for _,row in ipairs(self.rows) do
        infobox:node(row)
    end

    return tostring(infobox)
end

function p.main(frame)
    local args = getArgs(frame)
end

return Infobox