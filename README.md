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

* `rabbitmq`
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
`git:ref`             | Gitorious version | `v2.4.2`
`host`                | Host name | `gitorious.org`
`exception_notification_emails` | | `errors@gitorious.org`
`support_email`                 | | `support@gitorious.org`
`custom_username_label` | Used on the login page | `Username`
`mysql_database`      | Mysql database name | `gitorious`
`mysql_password`      | Mysql user password | `1234`
`use_ldap_for_authorization` | If this is set to false, all other ldap attributes are ignored | `true`
`ldap:host`           | | `ldap.gitorious.org`
`ldap:port`           | | `389`
`ldap:base_dn`        | | `DC=gitorious,DC=org`
`ldap:login_attribute`| | `CN`
`ldap:distinguished_name_template` | | `nil` (defaults to `$LOGIN_ATTRIBUTE={},$BASE_DN`)
`ldap:attribute_mapping` | | `{'displayName' => 'fullname', 'mail' => 'email'}`
`ldap:encryption`        | | `simple_tls`
`apache:ssl:cert_path`   | Location of Apache SSL certificate | `/etc/ssl/certs/ssl-cert-snakeoil.pem`
`apache:ssl:key_path`    | Location of Apache SSL key | `/etc/ssl/private/ssl-cert-snakeoil.key`
`stomp:host`             | Host to use for stomp | `localhost`
`stomp:port`             | Port to use for stomp | `61613`

Usage
=====

Just add `recipe[gitorious]` to the run list, it will set up the rabbitmq,
apache2, mysql and memcached servers and start the services.
