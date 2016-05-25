#
# Cookbook Name:: laravel5
# Recipe:: default
# This recipe is specifically used with only Laravel 5
#
# The recipe will detect the Framework using by checking the "APP_FW" environment variable
#
# Copyright 2015, Prapat Shantavasinkul
#
# All rights reserved - Do Not Redistribute
#
node[:deploy].each do |application, deploy|

	release_path = "#{deploy[:deploy_to]}/current"

	#if the framework is not Laravel 5, then skip
	if deploy[:environment_variables]['APP_FW'] != "L5"
		Chef::Log.info("Not Laravel 5")
		next
	end

	# write out .env file
	template "#{release_path}/.env" do
		source 'env.erb'
		mode '0660'
		owner deploy[:user]
		group deploy[:group]
		variables(
		  :env => deploy[:environment_variables]
		)
	end

	current_environment = deploy[:environment_variables]['APP_ENV']

	Chef::Log.info("Running composer")
	if(current_environment == 'production')
		execute "Running composer for production" do
		    cwd release_path
		    command "sudo composer install --no-interaction --no-dev --prefer-dist"
		end
	else
		execute "Running composer for dev environments" do
		    cwd release_path
		    command "sudo composer install"
		end
	end

	Chef::Log.info("Set ownership/permission for storage and cache folder")
	execute "chown #{release_path}/storage" do
	    command "chown -R #{deploy[:user]}:#{deploy[:group]} #{release_path}/storage"
	end
	execute "chmod #{release_path}/storage" do
	    command "chmod -R 775 #{release_path}/storage"
	end

	execute "chown #{release_path}/bootstrap/cache" do
	    command "chown -R #{deploy[:user]}:#{deploy[:group]} #{release_path}/bootstrap/cache"
	end
	execute "chmod #{release_path}/bootstrap/cache" do
	    command "chmod -R 775 #{release_path}/bootstrap/cache"
	end

	execute "Running artisan migrate" do
	    cwd release_path
	    user deploy[:group]
	    group deploy[:group]
	    command "php artisan migrate --force"
	end
end
