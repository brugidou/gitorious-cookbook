#
# Cookbook Name:: gitorious
# Recipe:: default
#
# Copyright 2012, Copyright 2012, Criteo
#

include_recipe "yum::epel" if platform_family? "rhel"

# We use ruby 1.8.x
node[:gitorious][:packages].each do |p|
  # make sure this runs *first*, so we can find the gem_path
  package p do
    action :nothing
  end.run_action(:install)
end

# deduce gem path
raise '"gem" not found' unless gem = `which gem`
gem_path = `gem env gemdir`+'/bin'
unless File.directory? gem_path
  case node[:platform_family]
  when "rhel"
    gem_path = "/usr/bin"
  else
    gem_path = "/usr/local/bin"
  end
end

include_recipe "rabbitmq"

ENV['HOME'] ||= "/root"

rabbitmq_plugin "rabbitmq_stomp" do
  action :enable
end

include_recipe "memcached"

gitorious_user = node[:gitorious][:user]
deploy_path = node[:gitorious][:deploy_path]
git_path = node[:gitorious][:git_path]

ENV['PATH'] = "#{gem_path}:#{ENV['PATH']}"

user gitorious_user do
  system true
  home deploy_path
end

directory deploy_path do
  owner gitorious_user
  recursive true
end

directory "#{deploy_path}/.ssh" do
  owner gitorious_user
  mode "700"
end

file "#{deploy_path}/.ssh/authorized_keys" do
  owner gitorious_user
  mode "600"
end

%w(repositories tarballs tarballs-work).each do |d|
  directory "#{git_path}/#{d}" do
    owner gitorious_user
    recursive true
  end
end

gem_package "bundler"

# Install gitorious mainline

git deploy_path do
  repository node[:gitorious][:git][:url]
  reference node[:gitorious][:git][:ref]
  user gitorious_user
  enable_submodules true
  action :sync
end

directory "#{deploy_path}/tmp/pids" do
  owner gitorious_user
  recursive true
end

execute "bundle --deployment --without development test" do
  cwd deploy_path
  user gitorious_user
end

# MySQL

include_recipe "mysql::ruby"
include_recipe "mysql::server"

mysql_database node[:gitorious][:mysql_database] do
  connection(
    :host => "localhost",
    :username => "root",
    :password => node[:mysql][:server_root_password]
  )
  action :create
end

mysql_database_user gitorious_user do
  connection(
    :host => "localhost",
    :username => "root",
    :password => node[:mysql][:server_root_password]
  )
  password node[:gitorious][:mysql_password]
  database_name node[:gitorious][:mysql_database]
  action [:create, :grant]
end

# Service definition

include_recipe "passenger_apache2::mod_rails"
include_recipe "apache2::mod_ssl"

gitorious_services = %w(git-daemon git-poller git-thinking-sphinx)

gitorious_services.each do |s|
  template "/etc/init.d/#{s}" do
    source "#{s}.erb"
    mode   "0755"
    variables(
      :gitorious_home => deploy_path,
      :gem_path => gem_path
    )
  end
end

# Config

require 'openssl'

def cookie_secret
  cs = String.new
  while cs.length < 30
    cs << ::OpenSSL::Random.random_bytes(1).gsub(/\W/, '')
  end
  cs
end

node.set_unless[:gitorious][:cookie_secret] = cookie_secret

confs = %w(gitorious database broker authentication)
confs.each do |config|
  template "#{deploy_path}/config/#{config}.yml" do
    source "#{config}.yml.erb"
    mode "0644"
    owner gitorious_user
    notifies :reload, "service[apache2]"
  end
end

template "/etc/logrotate.d/gitorious" do
  source "gitorious-logrotate.erb"
  owner "root"
  mode "0644"
  variables(
    :deploy_path => deploy_path,
    :gitorious_services => gitorious_services
  )
end

# Prepare DB and sphinx

execute "correct invalid gemspec dates" do
  command "find . -name '*.gemspec' | xargs sed -i 's/ 00:00:00\.000000000Z//'"
  cwd deploy_path
end

execute "bundle exec rake db:create db:migrate thinking_sphinx:configure" do
  cwd deploy_path
  environment(
    'RAILS_ENV' => 'production'
  )
  user gitorious_user
end

# Apache config

web_app "gitorious" do
  docroot "#{deploy_path}/public"
  server_name node[:gitorious][:host]
  server_aliases []
  rails_env "production"
  cookbook "passenger_apache2"
end

gitorious_ssl = case node[:platform_family]
                when "debian"
                  "/etc/apache2/sites-available/gitorious-ssl"
                when "rhel"
                  "/etc/httpd/sites-available/gitorious-ssl"
                end

template gitorious_ssl do
  source "gitorious-ssl.erb"
  owner "root"
  mode "0644"
  variables(
    :gitorious_path => deploy_path
  )
  notifies :reload, "service[apache2]"
end

apache_site "gitorious-ssl"

p = case node[:platform_family]
    when "debian"
      "sphinxsearch"
    when "rhel"
      "sphinx"
    end
package p

file "/usr/local/bin/gitorious" do
  mode "755"
  content <<EOF
#!/usr/bin/env dash

cd #{deploy_path}

RAILS_ENV=production bundle exec script/gitorious "$@"
EOF
end

# Start services

cron "gitorious_thinking_sphinx_reindexing" do
  user  gitorious_user
  command "cd #{deploy_path} && #{gem_path}/bundle exec rake thinking_sphinx:index RAILS_ENV=production 2>&1 >/dev/null"
end

# Work around CHEF-2345 for RHEL
status_cmd = lambda {|pattern| "ps -ef | grep #{pattern}" }

service "git-daemon" do
  action [:enable, :start]
  supports :reload => false, :restart => true, :status => false
  status_command status_cmd.call "git-daemon" if platform_family? "rhel"
  subscribes :restart, resources("template[/etc/init.d/git-daemon]")
  confs.each { |c| subscribes :restart, "template{#{deploy_path}/config/#{c}.yml]" }
end

service "git-poller" do
  action [:enable, :start]
  pattern "poller"
  supports :reload => false, :restart => true, :status => false
  status_command status_cmd.call "poller" if platform_family? "rhel"
  subscribes :restart, resources("template[/etc/init.d/git-poller]")
  confs.each { |c| subscribes :restart, "template{#{deploy_path}/config/#{c}.yml]" }
end

service "git-thinking-sphinx" do
  action [:enable, :start]
  pattern "searchd"
  supports :reload => false, :restart => true, :status => false
  status_command status_cmd.call "searchd" if platform_family? "rhel"
  subscribes :restart, resources("template[/etc/init.d/git-thinking-sphinx]")
  confs.each { |c| subscribes :restart, "template{#{deploy_path}/config/#{c}.yml]" }
end
