#
# Cookbook Name:: gitorious
# Recipe:: default
#
# Copyright 2012, Copyright 2012, Criteo
#

include_recipe "rabbitmq"

rabbitmq_plugin "rabbitmq_stomp" do
  action :enable
end

include_recipe "memcached"

gitorious_user = node[:gitorious][:user]
deploy_path = node[:gitorious][:deploy_path]
git_path = node[:gitorious][:git_path]
gem_path = "/var/lib/gems/1.8/bin"

ENV['PATH'] = "#{gem_path}:#{ENV['PATH']}"

user gitorious_user do
  system true
  home deploy_path
end

directory deploy_path do
  owner gitorious_user
  recursive true
end

directory "#{deploy_path}/tmp/pids" do
  owner gitorious_user
  recursive true
end

%w(repositories tarballs tarballs-work).each do |d|
  directory "#{git_path}/#{d}" do
    owner gitorious_user
    recursive true
  end
end

# We use ruby 1.8.x
%w(ruby ruby-dev rubygems git
   libxml2-dev libxslt1-dev
   libmysqlclient-dev).each do |p|
  package p
end

gem_package "bundler"

# Install gitorious mainline

git deploy_path do
  repository node[:gitorious][:git][:url]
  reference node[:gitorious][:git][:ref]
  user gitorious_user
  enable_submodules true
  action :checkout
end

execute "bundle --without development" do
  cwd deploy_path
  user "root"
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

template "#{deploy_path}/config/gitorious.yml" do
  source "gitorious.yml.erb"
  mode "0644"
  owner gitorious_user
end

template "#{deploy_path}/config/database.yml" do
  source "database.yml.erb"
  mode "0644"
  owner gitorious_user
end

template "#{deploy_path}/config/broker.yml" do
  source "broker.yml.erb"
  mode "0644"
  owner gitorious_user
end

template "#{deploy_path}/config/authentication.yml" do
  source "authentication.yml.erb"
  mode "0644"
  owner gitorious_user
end

cookbook_file "/etc/logrotate.d/gitorious" do
  source "gitorious-logrotate"
  owner "root"
  mode "0644"
end

# Services init.d

%w(git-daemon git-poller git-thinking-sphinx).each do |s|
  template "/etc/init.d/#{s}" do
    source "#{s}.erb"
    mode   "0755"
    variables(
      :gitorious_home => deploy_path,
      :gem_path => gem_path
    )
  end
end

# Apache config

include_recipe "passenger_apache2::mod_rails"
include_recipe "apache2::mod_ssl"

web_app "gitorious" do
  docroot "#{deploy_path}/public"
  server_name node[:gitorious][:host]
  server_aliases []
  rails_env "production"
  cookbook "passenger_apache2"
end

template "/etc/apache2/sites-available/gitorious-ssl" do
  source "gitorious-ssl.erb"
  owner "root"
  mode "0644"
  variables(
    :gitorious_path => deploy_path
  )
end

apache_site "default" do
  enable false
end

apache_site "gitorious-ssl"

#apache_site "gitorious-ssl"

# Prepare DB and sphinx

execute "bundle exec rake db:create db:migrate thinking_sphinx:configure" do
  cwd deploy_path
  environment(
    'RAILS_ENV' => 'production'
  )
end

# Services

service "git-daemon" do
  action [ :enable, :start ]
  supports :restart => true, :reload => false, :status => false
end

service "git-poller" do
  action [ :enable, :start ]
  pattern "poller"
  supports :restart => true, :reload => false, :status => false
end

service "git-thinking-sphinx" do
  action [ :enable, :start ]
  pattern "searchd"
  supports :restart => true, :reload => false, :status => false
end
