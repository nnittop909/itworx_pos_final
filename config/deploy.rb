require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
require 'mina/deploy'

set :domain, '192.168.254.105'
set :deploy_to, '/var/www/itworx_pos_final'
set :repository, 'https://github.com/nnittop909/itworx_pos_final.git'
set :branch, 'master'
set :user, 'deploy'
set :term_mode, nil
set :forward_agent, true
set :app_path, lambda { "#{fetch(:deploy_to)}/#{fetch(:current_path)}" }
set :stage, 'production'
set :shared_dirs, fetch(:shared_dirs, []).push('log', 'tmp/log', 'tmp/pids', 'tmp/sockets', 'public/system')
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')
# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
# set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-1.9.3-p125@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  command %[mkdir -p "#{fetch(:shared_path)}/log"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/log"]

  command %[mkdir -p "#{fetch(:shared_path)}/tmp/log"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/tmp/log"]

  command %[mkdir -p "#{fetch(:shared_path)}/config"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/config"]

  command %[mkdir -p "#{fetch(:shared_path)}/public/system"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/public/system"]

  command %[mkdir -p "#{fetch(:deploy_to)}/shared/tmp/pids"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/tmp"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/tmp/pids"]

  command %[mkdir -p "#{fetch(:deploy_to)}/shared/tmp/sockets"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/tmp/sockets"]

  command %[touch "#{fetch(:shared_path)}/config/database.yml"]
  command %[touch "#{fetch(:shared_path)}/config/secrets.yml"]
  command %[touch "#{fetch(:shared_path)}/tmp/log/stdout"]
  command %[touch "#{fetch(:shared_path)}/tmp/log/stderr"]
  command %[touch "#{fetch(:shared_path)}/tmp/pids/puma.pid"]
  command %[touch "#{fetch(:shared_path)}/tmp/sockets/puma.sock"]
  comment  %[echo "-----> Be sure to edit '#{fetch(:shared_path)}/config/database.yml' and 'secrets.yml'."]

  # if repository
  #   repo_host = repository.split(%r{@|://}).last.split(%r{:|\/}).first
  #   repo_port = /:([0-9]+)/.match(repository) && /:([0-9]+)/.match(repository)[1] || '22'

  #   command %[
  #     if ! ssh-keygen -H  -F #{repo_host} &>/dev/null; then
  #       ssh-keyscan -t rsa -p #{repo_port} -H #{repo_host} >> ~/.ssh/known_hosts
  #     fi
  #   ]
  # end

#########################################
desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'puma:restart'
    end
  end
end

namespace :puma do
  desc "Start the application"
  task :start do
    queue 'echo "-----> Start Puma"'
    queue "cd #{fetch(:app_path)} && RAILS_ENV=#{fetch(:stage)} && bin/puma.sh start"
  end

  desc "Stop the application"
  task :stop do
    queue 'echo "-----> Stop Puma"'
    queue "cd #{fetch(:app_path)} && RAILS_ENV=#{fetch(:stage)} && bin/puma.sh stop"
  end

  desc "Restart the application"
  task :restart do
    queue 'echo "-----> Restart Puma"'
    queue "cd #{fetch(:app_path)} && RAILS_ENV=#{fetch(:stage)} && bin/puma.sh restart"
  end
end

namespace :deploy do
  desc "reload the database with seed data"
  task :seed do
    invoke :'rbenv:load'
    queue "cd #{fetch(:app_path)}; bundle exec rails db:seed RAILS_ENV=#{fetch(:stage)}"
  end
end
end


