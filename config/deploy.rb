
# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

set :application, "strands"
set :repository, "http://tgl.textdriven.com/svn/#{application}/trunk"
set :checkout, "export"

role :web, "tgl.textdriven.com"
role :app, "tgl.textdriven.com"
role :db, "tgl.textdriven.com", :primary => true

set :deploy_to, "/users/home/tgl/domains/strnds.com/web" # defaults to "/u/apps/#{application}"
set :user, "tgl"

# =============================================================================
# TASKS
# =============================================================================

namespace :deploy do
  desc "The restart webserver"
  task :restart, :roles => :app do
    run "cd /users/home/tgl/domains/strnds.com/web/current; ./script/process/reaper -a reload"
  end
end

 desc "After updating code we need to populate a new database.yml"
task :after_update_code, :roles => :app do
  require "yaml"
  set :production_database_password, proc { Capistrano::CLI.password_prompt("Production database remote Password : ") }
  
  buffer = YAML::load_file('config/database.yml.template')
  # get ride of uneeded configurations
  buffer.delete('test')
  buffer.delete('development')
  
  # Populate production element
  buffer['production']['adapter'] = "postgresql"
  buffer['production']['database'] = "strands"
  buffer['production']['username'] = "tgl"
  buffer['production']['password'] = production_database_password
  buffer['production']['host'] = "localhost"
              
  put YAML::dump(buffer), "#{release_path}/config/database.yml", :mode => 0664
end

