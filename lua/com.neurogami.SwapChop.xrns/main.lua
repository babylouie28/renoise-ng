--[[============================================================================
com.neurogami.SwapChop.xrnx/main.lua

A tool to assist in swapping currently-active note column values.

Sort of like automating "mute" ; best used with full-pattern auto-seek samples.

Motivated by a desire to get a choppy scattered percussion effect.

Assumes you have two note columns: The current selected note column ("col1"), 
and one over to the right ("col2").

Takes two values for the audible volume value of notes in each column
Takes a space-separated list of line numbers.

It assumes col1 should start as "active" (i.e. audible).

First line, col1 gets assign its active column, col2 is set to 00.

For each line in the list of line numbers the active column alternates.

In each case one columns gets set to 00 and the other to its active volume.

When run, the tool will clear all column column values in the affected note columns.

The README is probably more upd-to-date than this comment :)


============================================================================]]--

require 'Utils'
require 'Core'
require 'Gui'

-- Reload the script whendever this file is saved. 
_AUTO_RELOAD_DEBUG = true

local function swap_columns_gui()
  GUI.current_text = ""
  GUI.show_dialog() 
--   local text = string.trim(GUI.current_text)
end



renoise.tool():add_menu_entry {
  name = "Pattern Editor:Neurogami SwapChop",
  invoke = swap_columns_gui
}





