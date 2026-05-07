GuildNotifier.gui = iup.hbox {}
GuildNotifier.gui_data = {
    wing_left = GuildNotifier.wings["SHOWN"].left,
    wing_right = GuildNotifier.wings["SHOWN"].right,
    icon = PROFILE_ICON or "",
    fgcolor1 = "",
    fgcolor2 = "",
    title = "Welcome",
    subtitle = "Pilot",
    msg = "Thanks for using Guild Notifier.\nHave a great journey!."
}

-- Create the gui to be displayed in HUD.
function GuildNotifier:create_gui()
    console_print("🔴 Begin of create_gui")
    local x_size =gkinterface.GetXResolution()
    local y_size =gkinterface.GetYResolution()
    local x_margin = (x_size - 324) / 2

    self.gui_icon_left = iup.label {title="", image = GuildNotifier.gui_data.icon, size="48x48", alignment = 'ACENTER'}
    self.gui_icon_right = iup.label {title="", image = GuildNotifier.gui_data.icon, size="48x48", alignment = 'ACENTER'}
    self.title = iup.label {title = GuildNotifier.gui_data.title, expand = 'HORIZONTAL', alignment = "ACENTER", wordwrap = 'YES'}
    self.subtitle = iup.label {title = GuildNotifier.gui_data.subtitle, expand = 'HORIZONTAL', alignment = "ACENTER", wordwrap = 'YES'}

    self.message = iup.label{title = GuildNotifier.gui_data.msg, alignment = "ACENTER", multiline = 'YES', wordwrap = 'YES', scrollbar = 'NO', expand = 'YES'}

    self.wing_left = iup.label {title="", image = GuildNotifier.gui_data.wing_left, size="128x64", alignment = 'ACENTER'}
    self.wing_right = iup.label {title="", image = GuildNotifier.gui_data.wing_right, size="128x64", alignment = 'ACENTER'}

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
                    self.wing_left,
                    iup.hbox {
                        iup.fill{size = -x_margin + 180},
                        self.gui_icon_left,
                        iup.fill{size = -x_margin + 180},
                    },
                    self.wing_right,
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
                    self.wing_left,
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
                    self.wing_right,
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
                    self.wing_left,
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
                    self.wing_right,
                },
                bottom_separator,
            },
            iup.fill{size = x_margin},
        }

    end
    console_print("🔴 End of create_gui")
    return true
end

-- Set the gui data to be displayed.
function GuildNotifier:set_gui_data(data)

    if not self.title or not self.gui then
        console_print("⚠️ Intent of update without a gui.")
        return
    end
    console_print("🔴 Begin of set_gui_data")
    self.gui_data.title = data.title or "-"
    self.gui_data.subtitle = data.subtitle or "-"
    self.gui_data.msg = data.msg or "-"
    self.title.title = self.gui_data.title
    self.subtitle.title = self.gui_data.subtitle
    self.message.title = self.gui_data.msg

    self:set_icon(data.icon)
    self:icon_blinker(250, 5)
    self:refresh()
    console_print("🔴 End of set_gui_data")
end

-- Set the icon to be displayed.
function GuildNotifier:set_icon(icon)
    self.gui_data.icon = GuildNotifier.icons[icon] or ""
    self.gui_icon_left.image = self.gui_data.icon
    self.gui_icon_right.image = self.gui_data.icon
end

-- Set the wings to be displayed.
function GuildNotifier:set_wings(wing)
	self.gui_data.wing_left = GuildNotifier.wings[wing].left or ""
	self.gui_data.wing_right = GuildNotifier.wings[wing].right or ""
	self.wing_left.image = self.gui_data.wing_left
	self.wing_right.image = self.gui_data.wing_right
end

-- Animate the icons with a blinking effect.
function GuildNotifier:icon_blinker(timeout, times)
    if not self.gui_icon_left or not self.gui_icon_right then
        return
    end

    local function blink(n)
    if n <= 0 then return end
        if not self.gui_icon_left or not self.gui_icon_right then return end
        self.gui_icon_left.size = '52x52'
        self.gui_icon_right.size = '52x52'
        GuildNotifier:refresh()
        Timer():SetTimeout(timeout, function()

         if not self.gui_icon_left or not self.gui_icon_right then return end
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

-- Make a transition between the gui states.
function GuildNotifier:fade(timeout, state)
    console_print("🔴 Begin of fade")
    if not GuildNotifier.states[state] then return false end
    if GuildNotifier.states[state] == GuildNotifier.state then return end

    GuildNotifier.state = GuildNotifier.states[state]

    if GuildNotifier.state == GuildNotifier.states["HIDDEN"]  then
        self:hide()
        return true
    else
        local function animate(s)
        --self:refresh()
        self:destroy_gui()
        self:init()
        end

        console_print("🔴 fade xpcall: ".. tostring(xpcall(animate, debug.traceback, 1)))

    end
    console_print("🔴 End of fade")
    return true
end
-- Refresh the gui.
function GuildNotifier:refresh()
    if GuildNotifier.states["HIDDEN"] ~= GuildNotifier.state then
        iup.Refresh(self.gui)
    end
end

-- Append the gui in the HUD.
function GuildNotifier:show()
    if GuildNotifier.states["HIDDEN"] ~= GuildNotifier.state then
        iup.Append(HUD.pluginlayer, self.gui)
        iup.Refresh(self.gui)
    end
end

-- Hide the gui.
function GuildNotifier:hide()
    iup.Detach(self.gui)
end

-- Destroy de gui.
function GuildNotifier:destroy_gui()
    if self.gui ~= nil then
        iup.Destroy(self.gui)
        self.gui = nil
    end
end

-- Create and show the gui.
function GuildNotifier:init()
    if not GuildNotifier.gn_enable then return end
    if self:create_gui() then
        self:show()
        console_print("🟢 GN: Starting...")
    else
        self:hide()
    end
end

-- Return true when the gui is added in the HUD and ready for notifications
function GuildNotifier:is_gui_ready()
    if xpcall(iup.GetParent, debug.traceback, self.gui) then
        return true
    end
    console_print("⛔ GN: gui is not ready yet!")
    return false
end

GuildNotifier:init()

-- Event handlers
function GuildNotifier:rHUDxscale(e, data)
    self:init()
end

RegisterEvent(GuildNotifier, 'rHUDxscale')

