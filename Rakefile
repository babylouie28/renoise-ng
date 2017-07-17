require 'facets/string/snakecase'
gem 'rubyzip'
gem 'zip-zip'
require 'zip/zip'
require 'zip/zipfilesystem'
require 'zip'
require 'find'

Dir.glob("tasks/*.rake") do |t|
  load t
end

V2 = '2.8.2'
V3 = '3.0.1'

tool_names = %w{
  SwapChop
  Alternator
  LoopComposer
  Conscripter
  Configgy
  RawMidi2
  OscJumper
  NewFromTemplate 
  RandyNoteColumns
  BeatMasher
  MisterMaster
  Generative
  TrackPatternComments
}

except = %w{Configgy RawMidi2 Generative }

desc "Edit JGB01.lua"
task :edit_terminal_lua do
Thread.new do

  sh "call v c:/Users/james/AppData/Roaming/Renoise/V3.1.0/Scripts/JGB01.lua"
end
sleep 3
end

task :copy_utils do
  Dir.chdir'lua' do
    tool_names.each do |name| 
      next if except.include? name     
      warn `cp com.neurogami.Utils.xrnx/Utilities.lua com.neurogami.#{name}.xrnx/#{name}/Utilities.lua `
    end
  end
end

desc "rebuild all"
task :rebuild =>  [:copy_utils] do
  tool_names.each do |tool| 
    Rake::Task["package:#{tool.snakecase}"].execute
  end
  if win32?
    warn "we are on win32 "
  sh "./__CP.bat"
  else
    warn "WE ARE ON NOT WIN32 "
  sh "./__cp.sh"
  end

end

desc "Copy over ./lua/GlobalOscActions.lua"
task :global do
  warn "This is hardcoded for Ubuntu"
  warn `cp ./lua/GlobalOscActions.lua /home/james/.renoise/V#{V2}/Scripts/`
  warn `cp ./lua/GlobalOscActions.lua /home/james/.renoise/V#{V3}/Scripts/`

  warn `cp ./lua/GlobalMidiActions.lua /home/james/.renoise/V#{V2}/Scripts/`
  warn `cp ./lua/GlobalMidiActions.lua /home/james/.renoise/V#{V3}/Scripts/`
  #  warn `cp ./lua/GlobalMidiActions.lua /home/james/.renoise/V3.0.0/Scripts/`

end

def zipit name, folder, input_filenames
  zipfile_name = "../com.neurogami.#{name}.xrnx"
  if File.exist? zipfile_name
    sh "rm #{zipfile_name}"
  end

  Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
    input_filenames.each do |filename|
      # Two arguments:
      # - The name of the file as it will appear in the archive
      # - The original file, including the path to find it
      zipfile.add(filename, folder + '/' + filename)
    end
  end
  copy_to_neurogami_dist zipfile_name
  sh "mv #{zipfile_name} ../dist/"
end

def win32?
  puts RUBY_PLATFORM
  RUBY_PLATFORM =~ /mingw32/ ? true : false
end

def ng_vhost
  case  hostname 
  when /james1/
    if win32?

        %~#{ENV['OWNCLOUD_FOLDER']}/vhosts/2012.neurogami.com~
    else
  %~/home/james/data/vhosts/2012.neurogami.com~
    end

  else
    raise "Undefined NG vhost for #{hostname}"
  end
end

def hostname 
  `hostname`.strip
end

def copy_to_neurogami_dist zipfile_name
  if File.exist? "#{ng_vhost}/content/renoise-tools/"
    sh "cp #{zipfile_name} #{ng_vhost}/content/renoise-tools/ "
  else
    warn "copy_to_neurogami_dist: Cannot find #{ng_vhost}/content/renoise-tools/ "
    exit
  end

end

def files tool_folder, exlude_patterns = []
  _ = []

  Dir.chdir(tool_folder) do
    Find.find(".") do |f|
      unless f =~ /^\.$|^\.\.$/
        f.sub! /^\.\//, ''
        _ << f 
      end
    end
  end

  exlude_patterns.each do |re|
    _.reject!{ |f|
      f =~ re
    }
  end

  warn _.inspect
  _
end

namespace :package do

  desc "Package up SharedCode"
  task :shared_code do
    Dir.chdir'lua' do
      name = 'SharedCode'
      folder = "com.neurogami.#{name}.xrnx" 
      input_filenames = files folder 
      zipit name, folder, input_filenames
    end
  end

  desc "Package up RandyNoteColumns"
  task :randy_note_columns do
    Dir.chdir'lua' do
      name = 'RandyNoteColumns'
      folder = "com.neurogami.#{name}.xrnx"
      input_filenames = files folder 
      zipit name, folder, input_filenames
    end
  end

  desc "Package up OscJumper"
  task :osc_jumper do
    Dir.chdir'lua' do
      name = 'OscJumper'
      folder = "com.neurogami.#{name}.xrnx"
      input_filenames = files folder 
      zipit name, folder, input_filenames
    end

  end

  desc "Package up NewFromTemplate"
  task :new_from_template do
    Dir.chdir'lua' do
      name = 'NewFromTemplate'
      folder = "com.neurogami.#{name}.xrnx"
      input_filenames = files folder, [ /config.xml/ ] 
      zipit name, folder, input_filenames
    end
  end


  desc "Package up MidiMapper"
  task :midi_mapping_demo do
    Dir.chdir'lua' do
      name = 'MidiMappingDemo'
      folder = "com.neurogami.#{name}.xrnx"
      input_filenames = %w{ main.lua manifest.xml Actions.lua  HandlersLaunchpad.lua  Handlers.lua  HandlersQuNexus.lua  }
      zipit name, folder, input_filenames
    end
  end

  desc "Package up RawMidi"
  task :raw_midi2 do
    Dir.chdir'lua' do
      name = "RawMidi2"
      folder = "com.neurogami.#{name}.xrnx"
      input_filenames = %w{ main.lua manifest.xml }
      zipit name, folder, input_filenames
    end
  end

  desc "Package up Configgy"
  task :configgy do
    Dir.chdir'lua' do
      name = "Configgy"
      folder = "com.neurogami.#{name}.xrnx"
      input_filenames = %w{ main.lua manifest.xml }
      zipit name, folder, input_filenames
    end
  end

  desc "Package up LoopComposer"
  task :loop_composer do
    Dir.chdir'lua' do
      name = "LoopComposer"
      folder = "com.neurogami.#{name}.xrnx"
      input_filenames = files folder
      zipit name, folder, input_filenames
    end
  end

 
  desc "Package up Alternator"
  task :alternator do
    Dir.chdir'lua' do
      name = "Alternator"
      folder = "com.neurogami.#{name}.xrnx"
      input_filenames = files folder
      zipit name, folder, input_filenames
    end
  end
  
  desc "Package up SwapChop"
  task :swap_chop do
    Dir.chdir'lua' do
      name = "SwapChop"
      folder = "com.neurogami.#{name}.xrnx"
      input_filenames = files folder
      zipit name, folder, input_filenames
    end
  end

    desc "Package up Conscripter"
  task :conscripter do
    Dir.chdir'lua' do
      name = "Conscripter"
      folder = "com.neurogami.#{name}.xrnx"
      input_filenames = files folder
      zipit name, folder, input_filenames
    end
  end




    desc "Package up BeatMasher"
  task :beat_masher do
    Dir.chdir'lua' do
      name = "BeatMasher"
      folder = "com.neurogami.#{name}.xrnx"
      input_filenames = files folder
      zipit name, folder, input_filenames
    end
  end

  desc "Package up MisterMaster"
  task :mister_master do
    Dir.chdir'lua' do
      name = "MisterMaster"
      folder = "com.neurogami.#{name}.xrnx"
      input_filenames = files folder
      zipit name, folder, input_filenames
    end
  end

  desc "Package up Generative"
  task :generative do
    Dir.chdir'lua' do
      name = "Generative"
      folder = "com.neurogami.#{name}.xrnx"
      input_filenames = files folder
      zipit name, folder, input_filenames
    end
  end


  desc "Package up TrackPatternComments"
  task :track_pattern_comments do
    Dir.chdir'lua' do
      name = "TrackPatternComments"
      folder = "com.neurogami.#{name}.xrnx"
      input_filenames = files folder
      zipit name, folder, input_filenames
    end
  end


end



