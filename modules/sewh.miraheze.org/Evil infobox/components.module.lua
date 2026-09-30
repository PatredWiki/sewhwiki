local Components = {}
require("Module:Mw.html extension")


-- helper functions
local function error(message)
    local error = mw.html.create("strong")
        :addClass("error")
        :wikitext("INFOBOX ERROR! " .. (message or "missingno"))

    return error
end

local function is(val, expected)
    return type(val) == expected
end

local function remove(str, pattern)
    if not is(str, "string") then
        return str
    end

    return str:gsub(pattern, "")
end


-- start
function Components.row(infobox, args)
    if not args[2] and not args.default then return end

    local row = mw.html.create("tr")
        :addClass("infobox-row")
        :th {
            args[1] or "No heading..."
        }
        :td {
            args[2] or args.default
        }
        :allDone()
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
        :allDone()
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
        :allDone()
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
        :allDone()
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
        :allDone()
        :addClasses(args.class)
        :addCss(args.css)

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
        :td {
            template,
            attr = {colspan = 2}
        }
        :allDone()
        :addClasses(args.class)
        :addCss(args.css)

    return currency
end

function Components.image(infobox, args)
    if args == false then return end

    local images = {}
    local size = args.size or 100

    for k,v in pairs(args) do
        if k:match("^image%d+$") then
            local id = tonumber(k:match("%d+"))
            images[id] = v
        end
    end

    local result

    local function makeImage(args)
        local width = args.width and remove(args.width, "px") or size
        local height = args.height and remove(args.height, "px") or width

        local bgwidth = args.bgwidth and remove(args.bgwidth, "px") or width
        local bgheight = args.bgheight and remove(args.bgheight, "px") or height

        local imagetext = ("[[File:%s|%spx]]"):format(
            remove(args.file, "File:"),
            width .. "x" .. height
        )

        local imagecaption = ""
        if args.caption then
            imagecaption = mw.html.create("div")
                :addClass("infobox-image-caption")
                :wikitextParsed(args.caption)
        end

        local imagediv = mw.html.create("div")
            :addClass("infobox-image")
            :css {
                ["--bg-width"] = bgwidth .. "px",
                ["--bg-height"] = bgheight .. "px"
            }
            :wikitext(imagetext)

        return tostring(imagediv) .. tostring(imagecaption)
    end

    if #images == 1 then
        result = makeImage(images[1])
    elseif #images > 1 then
        tabberargs = {}

        for k,v in ipairs(images) do
            local image = makeImage(v)

            tabberargs["tab" .. k] = v.name or "Image " .. k
            tabberargs["content" .. k] = image
        end

        result = frm:expandTemplate {
            title = "Tabber",
            args = tabberargs
        }
    else
        error("You need at least one image boi")
    end

    local row = mw.html.create("tr")
        :addClass("infobox-image-wrapper")
        :td {
            result,
            attr = {colspan = 2}
        }
        :allDone()
        :addClasses(args.class)
        :addCss(args.css)

    return row
end

return Components