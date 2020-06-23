#!/usr/bin/ruby
#
# Search for env variables named like ENV2CONF_<filename> = /path/to/conf/dir
#
# For each variable like this found, search for futher environement variables
# named like <filename>_<parameter> = value
#
# For each of these parameters, split out the parameter and value and write
# then out to the dest path and filename.
#
# For now this only writes out XML format.


#ENV["ENV2CONF_hdfs-site.xml"] = "./test_conf"
#ENV["ENV2CONF_core-site.xml"] = "./test_conf"
#ENV["hdfs-site.xml_foobar"] = "foobarval"
#ENV["hdfs-site.xml_bar"] = "barval"

def write_vars(prefix, dest)
  unless File.directory?(dest)
    puts "Destination #{dest} for #{prefix} does not exist"
    exit 1
  end
           
  fh = File.open(File.join(dest, prefix), "w")
  fh.puts "<?xml version=\"1.0\"?>\n<configuration>"
  ENV.keys.each do |k|
    unless k =~ /#{prefix}_(.+)/
      next
    end
    write_conf_var(fh, $1, ENV[k])
  end
  fh.puts "</configuration>"
  fh.close
end

def write_conf_var(fh, name, val)
  fh.puts "  <property>"
  fh.puts "    <name>#{name}</name>"
  fh.puts "    <value>#{val}</value>"
  fh.puts "  </property>"
end

def find_and_populate_config_files
  ENV.keys.each do |k|
    unless k =~ /ENV2CONF_(.+)$/
      next
    end
    unless ENV[k]
      puts "No destination set for #{k}"
      exit 1
    end
    write_vars($1, ENV[k])
  end
end

find_and_populate_config_files
