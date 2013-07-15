default[:gitorious][:deploy_path] = "/var/www/gitorious"
default[:gitorious][:git_path] = "/var/git/"
default[:gitorious][:user] = "git"

case node[:platform_family]
when "debian"
  default[:gitorious][:packages] = %w(ruby ruby-dev rubygems git
                                      libxml2-dev libxslt1-dev
                                      libmysqlclient-dev)
  default[:gitorious][:apache][:ssl][:cert_path] = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  default[:gitorious][:apache][:ssl][:key_path] = '/etc/ssl/private/ssl-cert-snakeoil.key'
when "rhel"
  default[:gitorious][:packages] = %w(ruby ruby-devel rubygems git
                                      libxml2-devel libxslt-devel)
  default[:gitorious][:apache][:ssl][:cert_path] = '/etc/pki/tls/certs/localhost.crt'
  default[:gitorious][:apache][:ssl][:key_path] = '/etc/pki/tls/private/localhost.key'
end

default[:gitorious][:git][:url] = "http://git.gitorious.org/gitorious/mainline.git"
default[:gitorious][:git][:ref] = "v2.4.12"

default[:gitorious][:host] = node[:fqdn] # "gitorious.org"
default[:gitorious][:exception_notification_emails] = "errors@gitorious.org"
default[:gitorious][:support_email] = "support@gitorious.org"
default[:gitorious][:custom_username_label] = "Username"

default[:gitorious][:mysql_database] = "gitorious"
default[:gitorious][:mysql_password] = "1234"

default[:gitorious][:use_ldap_for_authorization] = true

default[:gitorious][:ldap][:host] = "ldap.gitorious.org"
default[:gitorious][:ldap][:port] = 389
default[:gitorious][:ldap][:base_dn] = "DC=gitorious,DC=org" 
default[:gitorious][:ldap][:login_attribute] = "CN"
default[:gitorious][:ldap][:distinguished_name_template] = nil # defaults to $LOGIN_ATTRIBUTE={},$BASE_DN
default[:gitorious][:ldap][:attribute_mapping] = {
#  'displayName' => 'fullname',
  'mail' => 'email'
}
default[:gitorious][:ldap][:encryption] = 'simple_tls'


default[:gitorious][:stomp][:host] = 'localhost'
default[:gitorious][:stomp][:port] = 61613
