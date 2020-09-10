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
#ENV["hdfs-site.xml_sub"] = "fdf%%hdfs-site.xml_bar%%_therest"
#ENV["hdfs-site.xml_sub2"] = "fdf%%hdfs-site.xml_barnothere%%_therest"

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
    val = ENV[k]
    val = substitute_val(val)
    write_conf_var(fh, $1, val)
  end
  fh.puts "</configuration>"
  fh.close
end

# This routine will search the value passed in for a pattern like  %%CHARACTERS%%
# and if it finds a pattern like this, it will assume the value inside
# the double % symbols is another env variable. If so, it will replace
# %%CHARACTERS%% with the other environment variable. If the other env
# variable is not present, it will be replaced by empty string.
#
# Note only one replacement is attempted and the other env variable will
# not have any values substituted if there are any.
def substitute_val(val)
  if val =~ /(%%[^%]+%%)/
    # Replace the value like %%OTHER_ENV_VAR%% with the value of the
    # other env var, or nothing
    captured = $1
    replacement = ENV[$1.gsub("%%", "")]
    return val.gsub(/#{captured}/, replacement.nil? ? "" : replacement)
  end
  return val
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
