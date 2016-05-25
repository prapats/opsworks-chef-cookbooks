node[:deploy].each do |application, deploy|
	app_path = "#{deploy[:deploy_to]}"
	release_path = "#{app_path}/current"
	cache_path = "#{app_path}/shared/"

	# NPM install
	execute "move node_modules directory to the release path if existed" do
	    command "mv #{cache_path}/node_modules #{release_path}/node_modules"
	    only_if { File.exist?("#{cache_path}/node_modules") }
	    user deploy[:user]
	    group deploy[:group]
	end

	execute "Running npm install" do
	    cwd release_path
	    group deploy[:group]
	    only_if { File.exist?("#{release_path}/package.json") }
	    command "sudo npm install"
	    returns [0, '']
	end

	execute "copy updated node_modules directory back to the shared directory" do
	    command "cp -r #{release_path}/node_modules #{cache_path}/node_modules"
	    only_if { File.exist?("#{release_path}/node_modules") }
	    user deploy[:user]
	    group deploy[:group]
	end

	# Bower install
	execute "move bower_components directory to the release path if existed" do
	    command "mv #{cache_path}/bower_components #{release_path}/bower_components"
	    only_if { File.exist?("#{cache_path}/bower_components") }
	    user deploy[:user]
	    group deploy[:group]
	end

	execute "Run bower install" do
	    cwd release_path
	    only_if { File.exist?("#{release_path}/bower.json") }
	    group deploy[:group]
	    command "sudo bower install --allow-root"
	end

	execute "copy updated bower_components directory back to the shared directory" do
	    command "cp -r #{release_path}/bower_components #{cache_path}/bower_components"
	    only_if { File.exist?("#{release_path}/bower_components") }
	    user deploy[:user]
	    group deploy[:group]
	end

	# Gulp
	current_environment = deploy[:environment_variables]['APP_ENV']

	if current_environment!="production"
	    execute "Compile assets for development" do
	        cwd release_path
		    user deploy[:user]
		    group deploy[:group]
	    	only_if { File.exist?("#{release_path}/gulpfile.js") }
	        command "gulp"
	    end
	else
	    execute "Compile assets for production" do
	        cwd release_path
		    user deploy[:user]
		    group deploy[:group]
	    	only_if { File.exist?("#{release_path}/gulpfile.js") }
	        command "gulp --production"
	    end
	end
end
