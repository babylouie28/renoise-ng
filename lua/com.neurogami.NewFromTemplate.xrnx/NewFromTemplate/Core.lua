NewFromTemplate = {}

-- https://github.com/davidm/lua-glob-pattern
-- http://lua-users.org/wiki/DirTreeIterator
function NewFromTemplate.get_file_list(folder_path) 

  local extension = '*.xrns'

  local files = os.filenames(folder_path, extension)

  rprint(files)
  return files

end

function NewFromTemplate.menu_prefix()
  return "New from Template"
end


return NewFromTemplate 
