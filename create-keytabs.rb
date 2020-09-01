#!/usr/bin/ruby
#
# Expect to receive a single argument in the form:
#
#     principal:target_keytab principal2:target_keytab
#
# This script should create the new principal only if it
# does not already exist in the target keytab.

def remove_princ(princ)
  res = `kadmin -p root/admin -w password -q "delprinc -force #{princ}/$(hostname)"`
  if !$?.success?
    throw "Error when removing princ #{princ}: #{res}"
  end
end

def add_princ(princ)
  system("kadmin -p root/admin -w password -q \"addprinc -randkey #{princ}/$(hostname)\"")
end

def merge_into_target(princ, target)
  tmp_file = "/tmp/#{princ}.tmp.keytab"
  system("kadmin -p root/admin -w password -q \"xst -k /tmp/#{princ}.tmp.keytab #{princ}/$(hostname)\"")
  system("echo -e \"rkt #{tmp_file}\nwkt #{target}\nquit\" | ktutil")
  File.chmod(0644, target)
  File.delete(tmp_file)
end

inputs = ARGV[0].split(/\s/)

inputs.each do |p|
  parts = p.split(/:/)
  if parts.size != 2
    warn "Input #{p} is not in the form principal:target_keytab"
    next
  end
  # Check if the princ is already there in the target.
  remove_princ(parts[0])
  add_princ(parts[0])
  merge_into_target(parts[0], parts[1])
end

exit 0
