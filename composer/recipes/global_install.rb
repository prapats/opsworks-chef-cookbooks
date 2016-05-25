# Install composer
execute 'Download composer' do
	cwd "/tmp"
	command 'curl -sS https://getcomposer.org/installer | php'
	not_if { ::File.exists?('/usr/local/bin/composer') }
end

execute 'Install composer' do
	command 'sudo mv /tmp/composer.phar /usr/local/bin/composer'
	not_if { ::File.exists?('/usr/local/bin/composer') }
end