--[[============================================================================
com.neurogami.PatternJumper.xrnx/main.lua
============================================================================]]--



TOOL_NAME = "LoopComposer"

U = require 'LoopComposer/Utilities'
require 'LoopComposer/Core'
require 'LoopComposer/LoopHelpers'
require 'LoopComposer/Dumper'
require 'LoopComposer/Configuration'


package.path = os.currentdir() .. "../../UserConfig/?.lua;" .. package.path

-------------------------------------------------------------
--  http://forum.renoise.com/index.php/topic/38914-adding-song-notifiers-on-song-load/

local notifier = {}

function notifier.add(observable, n_function)
  if not observable:has_notifier(n_function) then
    observable:add_notifier(n_function)
  end
end

function notifier.remove(observable, n_function)
  if observable:has_notifier(n_function) then
    observable:remove_notifier(n_function)
  end
end


-- Set up song opening & closing observables
local new_doc_observable = renoise.tool().app_new_document_observable
local close_doc_observable = renoise.tool().app_release_document_observable


-- Set up notifier functions that are called when song opened or closed
local function open_song()
  print("A new song was opened")
  if have_config_file() then
--    print("Add the menu item ...")
  --  renoise.tool():add_menu_entry {
    --  name =  "--- Main Menu:Tools:Neurogami:" .. TOOL_NAME .. ":Load custom code",
   --   invoke = load_helper_code
    --}
    --  Just load the code. Too annoying to have to remember to do it by hand.
    --  Need to see if there would be a reason to want to make this manual,
    --  or if autoloading creates other issues, such as function conflicts.
    load_helper_code()
  end
end

local function attempt_remove_menu()
  renoise.tool():remove_menu_entry(menu_name)
end

local function close_song()
  pcall(attempt_remove_menu)
  print("Song was closed")
end


-- Add the notifiers
notifier.add(new_doc_observable, open_song)
notifier.add(close_doc_observable, close_song)

----------------

function helper_file_base_name()
  local name = U.base_file_name():gsub(" ", "_"):gsub(".xrns", "") .. "_LC"
  print(TOOL_NAME, ": Have song slug " .. name )
  return name
end

function have_config_file() 
  print(TOOL_NAME, ": Look for file ...")
  local file_name = os.currentdir() .. "../../UserConfig/" .. helper_file_base_name() .. ".lua"
  print(file_name)
  local f=io.open(file_name,"r")
  if f~=nil then io.close(f) return true else return false end
end


function load_helper_code()
  require(helper_file_base_name())
--  configurate();
end







