GN.delay = true
GN.delay_timer = nil

---@class gui
GN.gui = iup.hbox {}
GN.gui_data = {}

---Sets the gui data with initial values.
function GN:init_gui_data()
    self.gui_data = {
        wing_left = GN.wings["SHOWN"].left,
        wing_right = GN.wings["SHOWN"].right,
        icon = PROFILE_ICON or "",
        fgcolor1 = "",
        fgcolor2 = "",
        title = "Welcome",
        subtitle = "Pilot",
        msg = "Thanks for using Guild Notifier.\nHave a great journey!."
    }
end

---Get the icons and wings size according to OS Platform for IDLE state.
---@return string icons_size The size of the icons.
---@return string wings_size The size of the wings.
---@return integer wide The wide of the gui.
function GN.get_platform_size()
    local icons_size = "48x48"
    local wings_size = "128x64"
    local wide = 324
    if GN.state == GN.states["IDLE"] then
        if Platform == "iOS" or Platform == "Android" then
            icons_size = "24x24"
            wings_size = "64x32"
            wide = 162
        end
    end
    return icons_size, wings_size, wide
end

---Create the gui to be displayed in HUD.
function GN:create_gui()
    console_print("🔴 Begin of create_gui")
    local x_size =gkinterface.GetXResolution()
    local y_size =gkinterface.GetYResolution()
    local icons_size, wings_size, wide = GN.get_platform_size()
    local x_margin = (x_size - wide) / 2

    self.gui_icon_left = iup.label {title="", image = GN.gui_data.icon, size=icons_size, alignment = 'ACENTER'}
    self.gui_icon_right = iup.label {title="", image = GN.gui_data.icon, size=icons_size, alignment = 'ACENTER'}
    self.title = iup.label {title = GN.gui_data.title, expand = 'HORIZONTAL', alignment = "ACENTER", wordwrap = 'YES'}
    self.subtitle = iup.label {title = GN.gui_data.subtitle, expand = 'HORIZONTAL', alignment = "ACENTER", wordwrap = 'YES'}

    self.message = iup.label{title = GN.gui_data.msg, alignment = "ACENTER", multiline = 'YES', wordwrap = 'YES', scrollbar = 'NO', expand = 'YES'}

    self.wing_left = iup.label {title="", image = GN.gui_data.wing_left, size=wings_size, alignment = 'ACENTER'}
    self.wing_right = iup.label {title="", image = GN.gui_data.wing_right, size=wings_size, alignment = 'ACENTER'}

    local top_separator = iup.label {title = '', image = '', size = 'x1', expand = 'HORIZONTAL', fgcolor = '40 180 240 125 *'}
    local bottom_separator = iup.label {title = '', image = '', size = "x2", expand = 'HORIZONTAL',fgcolor = '40 180 240 125 *'}

    if GN.state == GN.states["HIDDEN"] then return false end
    if GN.state == GN.states["IDLE"]  then
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

    elseif GN.state == GN.states["SHOWN"] then
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

    elseif GN.state == GN.states["BATTLE"] then
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

---Set the gui data to be displayed.
---@param data table
function GN:set_gui_data(data)
    if GN.delay_timer and GN.delay_timer:IsActive() then return end
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

---Set the icon to be displayed.
---@param icon string The icon name associated to an event.
function GN:set_icon(icon)
    if GN.delay_timer and GN.delay_timer:IsActive() then return end
    self.gui_data.icon = GN.icons[icon] or ""
    self.gui_icon_left.image = self.gui_data.icon
    self.gui_icon_right.image = self.gui_data.icon
end

---Set the wings to be displayed.
---@param wing string The wing associated to mode.
function GN:set_wings(wing)
    if GN.delay_timer and GN.delay_timer:IsActive() then return end
	self.gui_data.wing_left = GN.wings[wing].left or ""
	self.gui_data.wing_right = GN.wings[wing].right or ""
	self.wing_left.image = self.gui_data.wing_left
	self.wing_right.image = self.gui_data.wing_right
end

---Animate the icons with a blinking effect.
---@param timeout integer The duration time of each blink in milliseconds.
---@param times integer The number of repetitions.
function GN:icon_blinker(timeout, times)
    if GN.delay_timer and GN.delay_timer:IsActive() then return end
    if not self.gui_icon_left or not self.gui_icon_right then
        return
    end

    local function blink(n)
    if n <= 0 then return end
        if not self.gui_icon_left or not self.gui_icon_right then return end
        self.gui_icon_left.size = '52x52'
        self.gui_icon_right.size = '52x52'
        GN:refresh()
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

---Sets the gui state and swaps the new gui state.
---@param state string A gui state to be set.
---@return boolean
function GN:set_gui_state(state)
    if GN.delay_timer and GN.delay_timer:IsActive() then return false end
    console_print("🔴 Begin of set_gui_state")
    if not GN.states[state] then return false end
    if GN.states[state] == GN.state then return false end

    GN.state = GN.states[state]

    if GN.state == GN.states["HIDDEN"]  then
        self:hide()
        return true
    else
        local function swap()
        self:hide()
        self:init()
        end

        console_print("🔴 set_gui_state xpcall: ".. tostring(xpcall(swap, debug.traceback)))

    end
    console_print("🔴 End of set_gui_state")
    return true
end

---Refresh the gui.
function GN:refresh()
    if GN.states["HIDDEN"] ~= GN.state and GN:is_gui_ready() then
        iup.Refresh(HUD.pluginlayer)
    end
end

---Append the gui in the HUD.
function GN:show()
    if GN.states["HIDDEN"] ~= GN.state then
        iup.Append(HUD.pluginlayer, self.gui)
        iup.Refresh(self.gui)
    end
end

---Hide the gui.
function GN:hide()
    iup.Detach(self.gui)
end

---Create and show the gui.
function GN:init()
    if not GN.gn_enable then return end
    if self:create_gui() then
        self:show()
        console_print("🟢 GN: Starting...")
    else
        self:hide()
    end
end

---Verify if the  gui is added in the HUD and ready for notifications.
---@return boolean
function GN:is_gui_ready()
    if self.gui == nil then return false end
    local success, resul = xpcall(iup.GetParent, debug.traceback, self.gui)
    if success and resul then return true end
    console_print("⛔ GN: gui is not ready yet!")
    return false
end

---@section EVENT_HANDLERS

---Applies a delay when HUD scales and resets GN gui.
---@param e string The game event rHUDxscale.
---@param data table The data for this event (ignored).
function GN:rHUDxscale(e)
    GN.delay = true
    GN:set_gui_state("HIDDEN")
    GN:set_gui_state("IDLE")
    GN.delay = false
    if GN.testing then
        print(e)
        print(os.time())
    end
end

---Shows the GN gui when HUD is shown.
---@param e string The game event HUD_SHOW.
function GN:HUD_SHOW(e)
    if not self:is_gui_ready() then
        self:init_gui_data()
        self:init()
    end
    GN.delay = false
    if GN.testing then
        print(e)
        print(os.time())
    end
end

---Applies a delay to notifications when HUD is hidden.
---@param e string The game event HUD_HIDE.
function GN:HUD_HIDE(e, data)
    GN.delay = true
    if GN.testing then
        print(e)
        print(os.time())
    end
end

RegisterEvent(GN, 'rHUDxscale')
RegisterEvent(GN, 'HUD_SHOW')
RegisterEvent(GN, 'HUD_HIDE')

---@end
