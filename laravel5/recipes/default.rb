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

    app_path = "#{deploy[:deploy_to]}"
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

	execute "move vendor directory to the release path if existed" do
        command "mv #{app_path}/shared/vendor #{release_path}/vendor"
        only_if { File.exist?("#{app_path}/shared/vendor") }
        user deploy[:user]
        group deploy[:group]
    end

	Chef::Log.info("Running composer")
	if(current_environment == 'production')
		execute "Running composer for production" do
		    cwd release_path
		    command "composer install --no-interaction --no-dev --prefer-dist"
            user deploy[:user]
            group deploy[:group]
		end
	else
		execute "Running composer for dev environments" do
		    cwd release_path
		    command "composer install --prefer-dist"
            user deploy[:user]
            group deploy[:group]
		end
	end

    execute "copy updated vendor directory back to the shared directory" do
        command "cp -r #{release_path}/vendor #{app_path}/shared/vendor"
        only_if { File.exist?("#{release_path}/vendor") }
        user deploy[:user]
        group deploy[:group]
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
