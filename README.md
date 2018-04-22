Apache
=========

Installs and configures Apache 2.x with virtual hosts.

Requirements
------------

A server or machine running Linux.

Role Variables
--------------

### General

```yml
apache_server_root: "{{ _apache_server_root[ansible_os_family] }}"
```
The `apache_server_root` variable defaults to the distribution specific location
of Apache. For RedHat based distributions this is usually **/etc/httpd**.

```yml
apache_vhost_base_directory: /var/www/vhosts
```
The `apache_vhost_base_directory` contains the location of where the vhosts
will live.

```yml
apache_vhost_directories:
  - backups
  - httpdocs
  - logs
  - private
  - subdomains
```

All sub-directories that are to be created for each vhost are defined in the
`apache_vhost_directories` list variable.

```yml
apache_custom_log_formats:
  - name: common
    format: "%h %l %u %t \"%r\" %>s %b"
```

Custom log formats are defined within the `apache_custom_log_formats` listed
dictionary variable.

```yml
apache_vhosts:
  - owner: apache
    group: apache
    server_name: example.com
    server_admin: webmaster@example.com
    server_aliases:
      - www.example.com
    custom_logs:
      - name: "access_log"
        format: "common"
    additional_directories:
      - directory_path: /some/other/path
        options:
          - AllowOverride All
          - Options -Indexes +FollowSymLinks
          - Require all granted
    custom_log:
    extra_config_options:
      - RewriteEngine on
      - RewriteCond %{SERVER_NAME} =example.com
      - RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]

apache_ssl_vhosts:
  - owner: apache
    group: apache
    server_name: example.com
    server_admin: webmaster@example.com
    server_aliases:
      - www.example.com
    custom_logs:
      - name: "access_log"
        format: "common"
    additional_directories:
      - directory_path: /var/www/vhosts/example.com/httpdocs
        options:
          - AllowOverride All
          - Options -Indexes +FollowSymLinks
          - Require all granted
    custom_logs: []
    cert_file: /etc/pki/tls/certs/localhost.crt
    cert_key_file: /etc/pki/tls/private/localhost.key
    cert_chain_file: /etc/pki/tls/certs/ca-bundle.crt
    ssl_options:
      - "SSLProtocol -all TLSv1.2"
      - "SSLHonorCipherOrder On"
      - "SSLCipherSuite ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS"
    extra_config_options:
      - RewriteEngine on
      - RewriteCond %{SERVER_NAME} =example.com
      - RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
```

Each non-SSL and SSL enabled vhosts are defined as a listed dictionary variable
called `apache_vhosts` and `apache_ssl_vhosts`, respectively. Both variables
are identical with the exception of SSL related elements in the
`apache_ssl_vhosts` dictionary list item.

- `owner` and `group` are there for the scenario involving the use of PHP with
PHP-FPM.
- `server_name` specifies the vhost that the item is for.
- `server_admin` contains the email for the site administrator.
- `server_aliases` is a listing of aliases for the domain specified in
`server_name`.
- `custom_logs` allows you to define one or more custom logs for the vhost in
a list variable.
  - `name` specifies the name of the file that log information will be written
  to.
  - `format` is the format that each entry is written in. This can either be a
  format string or the name of the format that had been defined in
  `apache_custom_log_formats`.
- `additional_directories` contains a list of each additional directory and
options for that directory for the vhost. The DocumentRoot configuration
entry does not need to be defined as it is automatically generated based on
the the `server_name` and `apache_vhost_base_directory` variables.
  - `directory_path` The full path to a directory that is to be served under
  the vhost. This can be outside the document root or within it.
  - `options` contain a list of Apache directives for the directory. All items
  are placed within opening and closing directory tags.
- `ssl_options` is a listing of SSL related configuration directives.
- `cert_file`, `cert_key_file`, and `cert_chain_file` contain the path for the
domain's certificate.
- `extra_config_options` is where any other configuration should be placed.
Each item represents one line.

Subdomains are intended to be treated as a separate vhost. When creating one, create a subdomain in either the `apache_vhosts` or `apache_ssl_vhosts` list dictionary add an item to the `additional_directories` list containing the directory for the subdomain; */var/www/vhosts/example.com/subdomains/subdomain/httpdocs*

```yml
apache_selinux_fcontexts:
  files:
    - spec:
  types:
      type: httpd_log_t
    - spec: /var/www/vhosts(/.*)?/backup(/.*)?
      type: httpd_sys_rw_content_t
    - spec: /var/www/vhosts(/.*)?/private(/.*)?
      type: httpd_sys_rw_content_t
    - spec: /var/www/vhosts(/.*)?/httpdocs/sites(/.*)?/files(/.*)?
      type: httpd_sys_rw_content_t
    - spec: /var/www/vhosts(/.*)?/backups(/.*)?
      type: httpd_sys_rw_content_t
    - spec: /var/www/vhosts(/.*)?/httpdocs/cache(/.*)?
      type: httpd_sys_rw_content_t
  roles:
    - spec:
      range:
  users:
    - spec:
      user:
```
If SELinux is enabled, file contexts will be added so content can be served.
When `apache_selinux_fcontexts` is not defined and SELinux is enabled on the
system, the default value is `_apache_selinux_fcontexts` will be used, which
is found in vars/main.yml.
```yml
apache_selinux_booleans:
  - httpd_can_network_connect_db
```
When SELinux is enabled, booleans may need to be set in order for sites to
work.

### Gentoo

```yml
apache_gentoo_flags:
  - ssl
  - threads
```

Additional use flags for the apache package can be set in `apache_gentoo_flags`.

```yml
_apache_gentoo_modules:
  - alias
  - auth_basic
  - auth_digest
  - authn_core
  - authz_core
  - authz_dbd
  - authz_host
  - authz_owner
  - authz_user
  - dbd
  - dir
  - headers
  - http2
  - include
  - log_config
  - log_forensic
  - mime
  - proxy
  - proxy_fcgi
  - rewrite
  - setenvif
  - socache_shmcb
  - spelling
  - status
  - unixd
  - userdir
  - vhost_alias
```

When installing Apache on a Gentoo system, common modules such as mod_rewrite
need to be specified. The `apache_gentoo_modules` contains a list of required
modules.

```yml
apache_gentoo_mpms:
  - worker
```

A list of Apache MPMs defined as a list.

```yml
apache_gentoo_opts: "-D DEFAULT_VHOST -D INFO -D SSL -D SSL_DEFAULT_VHOST -D PROXY"
```

Additional options that are passed to `apache2` command.

### RedHat

```yml
apache_rh_packages: "{{ _apache_rh_packages }}"
#  - httpd
#  - mod_ssl
```

Additional RedHat based Apache packages are listed in `apache_rh_packages`.
The default list includes the httpd and mod_ssl packages.

Dependencies
------------

N/A

Example Playbook
----------------
The variables listed above can be defined in either a group_vars file,
host_vars file, or within a play book.

```
---
- hosts: web-servers
  roles:
    - the-paulus.apache
```

License
-------

BSD
