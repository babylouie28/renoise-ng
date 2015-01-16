
require 'zip'
require 'zip/zip'
require 'zip/zipfilesystem'
require 'find'

Dir.glob("tasks/*.rake") do |t|
  load t
end

V2 = '2.8.2'
V3 = '3.0.1'


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

def ng_vhost
  case  hostname 
  when /james1/
  %~/home/james/data/vhosts/2012.neurogami.com~
  else
    raise "Undefined NG vhost for #{hostname}"
  end
end

def hostname 
  `hostname`.strip
end

def copy_to_neurogami_dist zipfile_name
  sh "cp #{zipfile_name} #{ng_vhost}/content/renoise-tools/ "
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
  task :shared do
    cd 'lua'
    name = 'SharedCode'
    folder = "com.neurogami.#{name}.xrnx" 
    input_filenames = files folder 
    zipit name, folder, input_filenames
  end

  desc "Package up RandyNoteColumns"
  task :randy_notes do
    cd 'lua'
    name = 'RandyNoteColumns'
    folder = "com.neurogami.#{name}.xrnx"
    input_filenames = files folder 
    zipit name, folder, input_filenames
  end

  desc "Package up OscJumper"
  task :osc_jumper do
    cd 'lua'
    name = 'OscJumper'
    folder = "com.neurogami.#{name}.xrnx"
    input_filenames = files folder 
    zipit name, folder, input_filenames
  end

  desc "Package up NewFromTemplate"
  task :new_from_template do
    cd 'lua'
    name = 'NewFromTemplate'
    folder = "com.neurogami.#{name}.xrnx"
    input_filenames = files folder, [ /config.xml/ ] 
    zipit name, folder, input_filenames
  end


  desc "Package up MidiMapper"
  task :midimapper do
    cd 'lua'
    name = 'MidiMappingDemo'
    folder = "com.neurogami.#{name}.xrnx"
    input_filenames = %w{ main.lua manifest.xml Actions.lua  HandlersLaunchpad.lua  Handlers.lua  HandlersQuNexus.lua  }
    zipit name, folder, input_filenames
  end

  desc "Package up RawMidi"
  task :raw_midi do
    cd 'lua'
    name = "RawMidi"
    folder = "com.neurogami.#{name }.xrnx"
    input_filenames = %w{ main.lua manifest.xml }
    zipit name, folder, input_filenames
  end

  desc "Package up Configgy"
  task :configgy do
    cd 'lua'
    name = "Configgy"
    folder = "com.neurogami.#{name }.xrnx"
    input_filenames = %w{ main.lua manifest.xml }
    zipit name, folder, input_filenames
  end

end

