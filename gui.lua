GuildNotifier.gui = iup.hbox {}
GuildNotifier.gui_data = {
    icon = PROFILE_ICON or "",
    fgcolor1 = "",
    fgcolor2 = "",
    title = "Welcome",
    subtitle = "Pilot",
    msg = "Thanks for using Guild Notifier.\nHave a great journey!."
}

function GuildNotifier:create_gui()
    local x_size =gkinterface.GetXResolution()
    local y_size =gkinterface.GetYResolution()
    local x_margin = (x_size - 324) / 2

--    local msg = "Tengo que pensar en algo mejor. Por ello voy a tratar de poner un texto muyyy largo con el                     objetivo de agrandar el label y ver si funiciona en incluso agregar otra \n linea al texto."

    self.gui_icon_left = iup.label {title="", image = GuildNotifier.gui_data.icon, size="48x48", alignment = 'ACENTER'}
    self.gui_icon_right = iup.label {title="", image = GuildNotifier.gui_data.icon, size="48x48", alignment = 'ACENTER'}
    self.title = iup.label {title = GuildNotifier.gui_data.title, expand = 'HORIZONTAL', alignment = "ACENTER", wordwrap = 'YES'}
    self.subtitle = iup.label {title = GuildNotifier.gui_data.subtitle, expand = 'HORIZONTAL', alignment = "ACENTER", wordwrap = 'YES'}
   -- local message = iup.label {title = msg  , expand = 'HORIZONTAL', alignment = "ACENTER", wordwrap = 'YES'}
    self.message = iup.label{title = GuildNotifier.gui_data.msg, alignment = "ACENTER", multiline = 'YES', wordwrap = 'YES', scrollbar = 'NO', expand = 'YES'}

    local wing_left = iup.label {title="", image = GuildNotifier.wing_left, size="128x64", alignment = 'ACENTER'}
    local wing_right = iup.label {title="", image = GuildNotifier.wing_right, size="128x64", alignment = 'ACENTER'}
    local top_separator = iup.label {title = '', image = '', size = 'x1', expand = 'HORIZONTAL', fgcolor = '40 180 240 125 *'}
    local bottom_separator = iup.label {title = '', image = '', size = "x2", expand = 'HORIZONTAL',fgcolor = '40 180 240 125 *'}

    if GuildNotifier.state == GuildNotifier.states["HIDDEN"] then return false end
    if GuildNotifier.state == GuildNotifier.states["IDLE"]  then
       -- print("IDLE")
        self.gui = iup.hbox{
            iup.fill{size = x_margin},
            iup.vbox{
                iup.fill{},
                iup.hbox {
                    wing_left,
                    iup.hbox {
                        iup.fill{size = -x_margin + 180},
                        self.gui_icon_left,
                        iup.fill{size = -x_margin + 180},
                    },
                    wing_right,
                    gap = 5,
                },

                iup.fill{size = 1},
            },
            iup.fill{size = x_margin},
        }

    elseif GuildNotifier.state == GuildNotifier.states["SHOWN"] then
     --   print("SHOWN")

        x_margin = (x_size - 800 ) /2

        self.gui = iup.hbox{
            iup.fill{size = x_margin},
            iup.vbox {
                iup.fill{size = y_size - 175},
                iup.hbox {
                    wing_left,
                    iup.hbox{
                        self.gui_icon_left,
                    },
                    iup.vbox {
                        top_separator,
                        self.title,
                        self.subtitle,
                        gap = '5',
                        iup.hbox {
                            iup.fill{size = -x_margin + 400},
                            self.message,
                            iup.fill{size = -x_margin + 400},
                        },
                    },
                    iup.hbox{
                        self.gui_icon_right,
                    },
                    wing_right,
                },
                bottom_separator,
            },
            iup.fill{size = x_margin},
        }

    elseif GuildNotifier.state == GuildNotifier.states["BATTLE"] then
       -- print("BATTLE")

        x_margin = (x_size - 650 ) /2

        self.gui = iup.hbox{
            iup.fill{size = x_margin},
            iup.vbox {
                iup.fill{size = y_size - 175},
                iup.hbox {
                    wing_left,
                    self.gui_icon_left,
                    iup.vbox {
                        top_separator,
                        self.title,
                        self.subtitle,
                        gap = '5',
                        iup.hbox {
                            iup.fill{size = -x_margin + 325},
                            self.message,
                            iup.fill{size = -x_margin + 325},
                        },
                    },
                    self.gui_icon_right,
                    wing_right,
                },
                bottom_separator,
            },
            iup.fill{size = x_margin},
        }

    end

    return true
end

function GuildNotifier:set_gui_data(data)
    self.gui_data.title = tostring(data.title or "")
    self.gui_data.subtitle = tostring(data.subtitle or "")
    self.gui_data.msg = tostring(data.msg or "")
    self.title.title = self.gui_data.title
    self.subtitle.title = self.gui_data.subtitle
    self.message.title = self.gui_data.msg
    local icon = tostring(data.icon or "IDLE")
    self:set_icon(icon)
    self:icon_blinker(250, 5)
    self:refresh()
end

function GuildNotifier:set_icon(icon)
    self.gui_data.icon = tostring(GuildNotifier.icons[icon] or "")
    self.gui_icon_left.image = self.gui_data.icon
    self.gui_icon_right.image = self.gui_data.icon
    console_print("set_icon: [".. tostring(self.gui_data.icon).."]")
end

function GuildNotifier:icon_blinker(timeout, times)
    local function blink(n)
    if n <= 0 then return end
        self.gui_icon_left.size = '52x52'
        self.gui_icon_right.size = '52x52'
        GuildNotifier:refresh()
        Timer():SetTimeout(timeout, function()
            self.gui_icon_left.size = '48x48'
            self.gui_icon_right.size = '48x48'
            self:refresh()

            Timer():SetTimeout(timeout, function()
                blink(n - 1)
                return
            end)
        end)

    end
    blink(times)
end

function GuildNotifier:fade(timeout, state)
 --   print(state)
    if not GuildNotifier.states[state] then return false end
    if GuildNotifier.states[state] == GuildNotifier.state then return end

    GuildNotifier.state = GuildNotifier.states[state]

    if GuildNotifier.state == GuildNotifier.states["HIDDEN"]  then
        self:hide()
        return true
    else

        local function animate(s)
            if s <= 0 then
                return
            end
           -- self:refresh()
            self:destroy_gui()
            Timer():SetTimeout(timeout, function()
                self:init()
                animate(s - 1)
                return
            end)
        end
        animate(1)

    end
    return true
end

function GuildNotifier:refresh()
    if GuildNotifier.states["HIDDEN"] ~= GuildNotifier.state then
        iup.Refresh(self.gui)
    end
end

function GuildNotifier:show()
    if GuildNotifier.states["HIDDEN"] ~= GuildNotifier.state then
        iup.Append(HUD.pluginlayer, self.gui)
        iup.Refresh(self.gui)
       -- GuildNotifier.state = GuildNotifier.states["IDLE"]
    end
end

function GuildNotifier:hide()
    iup.Detach(self.gui)
end

function GuildNotifier:destroy_gui()
    if self.gui ~= nil then
        iup.Destroy(self.gui)
        self.gui = nil
    end
end

function GuildNotifier:init()
    if not GuildNotifier.gn_enable then return end
    --  if GuildNotifier.mode_sound then return end
    if self:create_gui() then
        self:show()
        console_print("Starting...")
    else
        self:hide()
    end
end

GuildNotifier:init()

-- Event handlers
function GuildNotifier:rHUDxscale(e, data)
    --print("Antes del sesastre")
    self:init()
end

RegisterEvent(GuildNotifier, 'rHUDxscale')

