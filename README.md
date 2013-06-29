Description
===========

Installs gitorious (http://gitorious.org/gitorious) on a single server.

Requirements
============

Platform
--------
Tested on: 

* Debian stable (6.0.6)
* Ubuntu Precise (12.04)

It uses package Rubygems 1.8.X from apt, plus a small hack to find gem binaries. 
Depending on the Debian/Ubuntu policy, these are sometimes in 
`/var/lib/gems/1.8/bin`, other times in `/usr/local/bin`.

Dependencies
------------

* `stompserver`
* `passenger_apache2`
* `mysql`
* `database` (for the `mysql` providers)
* `memcached`

Attributes
==========

Attribute | Description | Default
----------|-------------|--------
`deploy_path`         | Where the gitorious source code checkout will be | `/var/www/gitorious`
`git_path`            | Where the git repositories will be stored | `/var/git`
`user`                | System user for gitorious services | `git`
`git:url`             | URL for the gitorious source code | `http://git.gitorious.org/gitorious/mainline.git`
`git:ref`             | Gitorious version | `v2.4.12`
`host`                | Host name | `node.name`
`public_mode`         | If true you can see projects without needing to login, and do read only clones | `false`
`hide_http`           | If true gitorious will not show http as a method to clone a repository | `false`
`admin_project`       | If true only admin users can create new projects | `true`
`enable_openid`       | If true enable openid | `false`
`exception_notification_emails` | | `errors@gitorious.org`
`support_email`                 | | `support@gitorious.org`
`custom_username_label` | Used on the login page | `Username`
`mysql_database`      | Mysql database name | `gitorious`
`mysql_password`      | Mysql user password | `1234`
`use_ldap_for_authorization` | If this is set to false, all other ldap attributes are ignored | `true`
`ldap:host`            | | `ldap.gitorious.org`
`ldap:port`            | | `636`
`ldap:base_dn`         | | `DC=gitorious,DC=org`
`ldap:group_search_dn` | Base DN when searching for groups. Need to uncomment in authentication.yml.erb if you want to use it| `ou=Groups,dc=gitorious,dc=org`
`ldap:login_attribute` | | `CN`
`ldap:distinguished_name_template` | | `nil` (defaults to `$LOGIN_ATTRIBUTE={},$BASE_DN`)
`ldap:attribute_mapping` | | `{'displayName' => 'fullname', 'mail' => 'email'}`
`ldap:encryption`        | | `simple_tls`
`ldap:bind_user`         | Username to use for authenticated bind | `admin_user`
`ldap:bind_pass`         | Password to use for authenticated bind | `admin_pass`
`apache:ssl:cert_path`   | Location of Apache SSL certificate | `/etc/ssl/certs/ssl-cert-snakeoil.pem`
`apache:ssl:key_path`    | Location of Apache SSL key | `/etc/ssl/private/ssl-cert-snakeoil.key`
`stomp:host`             | Host to use for stomp | `localhost`
`stomp:port`             | Port to use for stomp | `61613`

Usage
=====

Just add `recipe[gitorious]` to the run list, it will set up the rabbitmq,
apache2, mysql and memcached servers and start the services.
