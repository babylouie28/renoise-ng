--[[============================================================================
com.neurogami.Configgy.xrnx/main.lua
============================================================================]]--



package.path = os.currentdir() .. "../../UserConfig/?.lua;" .. package.path

local menu_name = "Main Menu:Tools:Neurogami Configgy"

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
    print("Add the menu item ...")
    renoise.tool():add_menu_entry {
      name = menu_name,
      invoke = load_and_execute_config
    }
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

function song_slug()
  local name = renoise.song().name:gsub(" ", "_")
  print("Have song slug " .. name )
  return name
end

function have_config_file() 
  print("Configgy: Look for file ...")
  local file_name = os.currentdir() .. "../../UserConfig/" .. song_slug() .. ".lua"
  print(file_name)
  local f=io.open(file_name,"r")
  if f~=nil then io.close(f) return true else return false end
end


function load_and_execute_config()
  require(song_slug())
  configurate();
end




