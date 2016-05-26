include_recipe 'apache2'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end
  next if node[:deploy][application][:database].nil?

  bash "Enable network database access for httpd" do
    boolean = "httpd_can_network_connect_db"
    user "root"
    code <<-EOH
      semanage boolean --modify #{boolean} --on
    EOH
    not_if { OpsWorks::ShellOut.shellout("/usr/sbin/getsebool #{boolean}") =~ /#{boolean}\s+-->\s+on\)/ }
    only_if { platform_family?("rhel") && ::File.exist?("/usr/sbin/getenforce") && OpsWorks::ShellOut.shellout("/usr/sbin/getenforce").strip == "Enforcing" }
  end
end

include_recipe 'apache2::mod_php5'
