maintainer       "Copyright 2012, Criteo"
maintainer_email "m.brugidou@criteo.com"
license          "Apache 2.0"
description      "Installs/Configures gitorious"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "2.1.0"
depends          "rabbitmq", ">= 2.0.0"
depends          "passenger_apache2"
depends          "mysql"
depends          "database"
depends          "memcached"

%w(centos redhat ubuntu debian).each do |os|
  supports os
end
