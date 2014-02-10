
require 'zip'


namespace :package do
  desc "Package up OscJumper"
  task :osc_jumper do
    cd 'lua'


    folder = "com.neurogami.OscJumper.xrnx"
    input_filenames = %w{ main.lua manifest.xml OscJumper/Handlers.lua  OscJumper/Notifier.lua OscJumper/Preferences.lua   OscJumper/Utils.lua }

    zipfile_name = "../com.neurogami.OscJumper.xrnx"

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      input_filenames.each do |filename|
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(filename, folder + '/' + filename)
      end

      #  zipfile.get_output_stream("myFile") { |os| os.write "myFile contains just this" }
    end

  end
end

