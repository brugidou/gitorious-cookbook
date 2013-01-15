Description
===========

Installs gitorious (http://gitorious.org/gitorious) on a single server.

Requirements
============

Platform
--------
Tested on Debian stable (6.0.6), it uses the packaged ruby 1.8.X and there is a 
small hack to get gems in the PATH from /var/lib/gems/1.8/bin

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
`use_ldap_for_authorization` | | `true`
`ldap:host`           | | `ldap.gitorious.org`
`ldap:port`           | | `389`
`ldap:base_dn`        | | `DC=gitorious,DC=org`
`ldap:login_attribute`| | `CN`
`ldap:distinguished_name_template` | | `nil` (defaults to `$LOGIN_ATTRIBUTE={},$BASE_DN`)
`ldap:attribute_mapping` | | `{'displayName' => 'fullname', 'mail' => 'email'}`
`ldap:encryption`        | | `simple_tls`

Usage
=====

Just add `recipe[gitorious]` to the run list, it will set up the rabbitmq,
apache2, mysql and memcached servers and start the services.
