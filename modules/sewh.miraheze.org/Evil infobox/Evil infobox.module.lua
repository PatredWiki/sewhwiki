-- still a wip

local p = {}
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


-- components
local Components = {}

function Components.row(infobox, args)
    local row = mw.html.create("tr")
        :addClass("infobox-row")
        :th {
            args[1] or "No heading..."
        }
        :td {
            args[2] or "No data..."
        }
        :addClasses(args.class)
        :addCss(args.css)

    return row
end

function Components.title(infobox, args)
    local title = mw.html.create("tr")
        :addClass("infobox-title")
        :th {
            args[1] or "No title...",
            attr = {colspan = 2},
            css = {
                ["-webkit-text-stroke"] = "4px black",
                ["paint-order"] = "stroke fill"
            }
        }
        :addClasses(args.class)
        :addCss(args.css)

    return title
end

function Components.subtitle(infobox, args)
    local subtitle = mw.html.create("tr")
        :addClass("infobox-subtitle")
        :th {
            args[1] or "No subtitle...",
            attr = {colspan = 2},
            css = {
                ["-webkit-text-stroke"] = "4px black",
                ["paint-order"] = "stroke fill"
            }
        }
        :addClasses(args.class)
        :addCss(args.css)

    return subtitle
end

function Components.header(infobox, args)
    local header = mw.html.create("tr")
        :addClass("infobox-header")
        :th {
            args[1] or "No heading...",
            attr = {colspan = 2},
            css = {
                ["-webkit-text-stroke"] = "4px black",
                ["paint-order"] = "stroke fill"
            }
        }
        :addClasses(args.class)
        :addCss(args.css)

    return header
end

function Components.textarea(infobox, args)
    local textarea = mw.html.create("tr")
        :addClass("infobox-textarea")
        :td {
            args[1] or "No text here...",
            attr = {colspan = 2}
        }
        :addClasses(args.class)
        :addCss(args.css)

    return textarea
end

function Components.currency(infobox, args)
    local frm = mw.getCurrentFrame()
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
        :td {
            template,
            attr = {colspan = 2}
        }
        :addClasses(args.class)
        :addCss(args.css)

    return currency
end

function Components.image(infobox, args)
    -- nothing yet woohoo
end

-- infobox
local Infobox = {}
Infobox.__index = Infobox
Infobox.__tostring = Infobox.tostring

local pagename = mw.title.getCurrentTitle().fullText


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
    local infobox = mw.html.create("div")

    addClasses(infobox, {"infobox-wrapper", "infobox", "border--beveled-background"})
    addCss(infobox, {height = "fit-content"})

    for _,row in ipairs(self.rows) do
        infobox.node(row)
    end

    return tostring(infobox)
end

function p.main(frame)
    local args = getArgs(frame)
end

return p