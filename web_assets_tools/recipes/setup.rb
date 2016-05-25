execute "add external PPA for Node.js v6" do
    command "curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -"
end

package 'nodejs'

execute "install bower and gulp globally" do
    command "sudo npm install -g bower && sudo npm install --global gulp-cli"
end
