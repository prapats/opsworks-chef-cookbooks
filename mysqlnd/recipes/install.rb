apt_package "php5-mysqlnd" do
  action :install
end

 service "apache2" do
 	action :restart
 end