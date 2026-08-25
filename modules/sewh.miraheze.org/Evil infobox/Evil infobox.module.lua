-- still a wip

local p = {}
local getArgs = require("Module:Arguments").getArgs


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

local function addClasses(el, classes)
    if not classes then return end

    if is(classes, "string") then
        el:addClass(classes)
    elseif is(classes, "table") then
        for _,c in pairs(classes) do
            el:addClass(c)
        end
    end
end

local function addCss(el, css)
    if not css then return end

    if is(css, "string") then
        el:cssText(css)
    elseif is(css, "table") then
        el:css(css)
    end
end


-- components
local Components = {}

function Components.row(infobox, args)
    local row = mw.html.create("tr")
        :addClass("info-row")
        :tag("th")
            :wikitext(args.heading or "No heading...")
            :done()
        :tag("td")
            :wikitext(args.data or "No data...")
            :done()

    addClasses(row, args.class)
    addCss(row, args.css)

    return row
end

function Components.header(infobox, args)
    local header = mw.html.create("tr")
        :addClass("info-header")
        :tag("th")
            :attr("colspan", 2)
            :css{
                ["-webkit-text-stroke"] = "4px black",
                ["paint-order"] = "stroke fill"
            }
            :wikitext(args.heading or "No heading...")
            :done()

    addClasses(header, args.class)
    addCss(header, args.css)

    return header
end


-- infobox
local Infobox = {}
local Infobox.__index = Infobox
local Infobox.__tostring = Infobox.tostring

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

function p.main(frame)
    local args = getArgs(frame)
end

return p