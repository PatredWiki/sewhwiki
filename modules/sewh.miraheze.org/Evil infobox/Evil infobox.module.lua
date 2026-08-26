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
        :addClass("infobox-row")
        :tag("th")
            :wikitext(args[1] or "No heading...")
            :done()
        :tag("td")
            :wikitext(args[2] or "No data...")
            :done()

    addClasses(row, args.class)
    addCss(row, args.css)

    return row
end

function Components.title(infobox, args)
    local title = mw.html.create("tr")
        :addClass("infobox-title")
        :tag("th")
            :attr("colspan", 2)
            :css{
                ["-webkit-text-stroke"] = "4px black",
                ["paint-order"] = "stroke fill"
            }
            :wikitext(args[1] or "No title...")
            :done()

    addClasses(title, args.class)
    addCss(title, args.css)

    return title
end

function Components.subtitle(infobox, args)
    local subtitle = mw.html.create("tr")
        :addClass("infobox-subtitle")
        :tag("th")
            :attr("colspan", 2)
            :css{
                ["-webkit-text-stroke"] = "4px black",
                ["paint-order"] = "stroke fill"
            }
            :wikitext(args[1] or "No subtitle...")
            :done()

    addClasses(subtitle, args.class)
    addCss(subtitle, args.css)

    return subtitle
end

function Components.header(infobox, args)
    local header = mw.html.create("tr")
        :addClass("infobox-header")
        :tag("th")
            :attr("colspan", 2)
            :css{
                ["-webkit-text-stroke"] = "4px black",
                ["paint-order"] = "stroke fill"
            }
            :wikitext(args[1] or "No heading...")
            :done()

    addClasses(header, args.class)
    addCss(header, args.css)

    return header
end

function Components.textarea(infobox, args)
    local textarea = mw.html.create("tr")
        :addClass("infobox-textarea")
        :tag("td")
            :attr("colspan", 2)
            :wikitext(args[1] or "No text here...")
            :done()

    addClasses(textarea, args.class)
    addCss(textarea, args.css)

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
        :tag("td")
            :attr("colspan", 2)
            :wikitext(template)
            :done()

    addClasses(currency, args.class)
    addCss(currency, args.css)

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

    return infobox
end

function p.main(frame)
    local args = getArgs(frame)
end

return p