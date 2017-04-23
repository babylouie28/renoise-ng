--[[============================================================================
com.neurogami.Generative.xrnx/main.lua
============================================================================]]--


TOOL_NAME = "Generative"

U = require (TOOL_NAME .. '/Utilities')
require (TOOL_NAME .. '/Core')
require (TOOL_NAME .. '/LoopHelpers')
require (TOOL_NAME .. '/Dumper')
require (TOOL_NAME .. '/Configuration')

local menu_name = "--- Main Menu:Tools:Neurogami:Generative:Play"
package.path = os.currentdir() .. "../../UserConfig/?.lua;" .. package.path

-------------------------------------------------------------
--  http://forum.renoise.com/index.php/topic/38914-adding-song-notifiers-on-song-load/

local notifier = {}
local have_script = false

-- Problem: If we run this again we get an error about
-- timer functions already registered.
function play_script()
  read_comments()
  print("Now we need to execute the script!")
--  read_comments()
  Generative.go()
end

function read_comments()
  have_script = false 
  Generative.raw_script_text = ""

  for i, v in ipairs(renoise.song().comments) do 
  
    if (have_script) then
      print(i, v) 
      Generative.raw_script_text = Generative.raw_script_text  .. "\n" ..  v
    end
    
    if ( string.find(v, "- script -") ) then
      have_script = true
    end
   
  end
  
  -- `comments` is  a table of strings.
  
  print("Generative.raw_script_text is set to " .. Generative.raw_script_text )

  -- We might want to keep the table structure but only keep script lines.
  -- Perhaps we loop over the lines and look for some demarcation string
  -- and everything after that is the script.
end


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
  
  read_comments()

  if have_script then
    print("Add the menu item ...")
      
    renoise.tool():add_menu_entry {
      name = menu_name,
      invoke = play_script
    }

      
      --  renoise.tool():add_menu_entry {
    --  name =  "--- Main Menu:Tools:Neurogami:" .. TOOL_NAME .. ":Load custom code",
   --   invoke = load_helper_code
    --}
    --  Just load the code. Too annoying to have to remember to do it by hand.
    --  Need to see if there would be a reason to want to make this manual,
    --  or if autoloading creates other issues, such as function conflicts.
    ---- load_helper_code()
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








