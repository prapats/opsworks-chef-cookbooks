
execute "add software-properties-common" do
    command "sudo apt-get -y install software-properties-common"
end

execute "add external PPA for php 7.0 packages" do
    command "sudo add-apt-repository ppa:ondrej/php"
end

execute "update the local package cache" do
    command "sudo apt-get update"
end

execute "remove php5" do
    command "sudo apt-get purge php5-fpm && sudo apt-get --purge autoremove"
end

execute "install php 7.0" do
    command "sudo apt-get --yes --force-yes install php7.0-fpm php7.0-mysql php7.0-curl php7.0-gd php7.0-json php7.0-mcrypt php7.0-opcache php7.0-xml php7.0-mbstring php7.0-soap"
end

execute "install php for apache" do
    command "sudo apt install --yes --force-yes php libapache2-mod-php"
    returns [0,1]
end

execute "disable php5 and enable php7" do
    command "sudo a2dismod php5 && sudo a2enmod php7.0"
    returns [0,1]
end

service "apache2" do
    action :restart
end

