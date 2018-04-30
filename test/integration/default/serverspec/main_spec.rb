require 'serverspec'

set :backend, :exec

describe package('httpd'), :if => os[:family] == 'redhat' do
  it { should be_installed }
end

describe package('apache2'), :if => os[:family] == 'gentoo' do
  it { should be_installed }
end

describe port(80) do
  it { should be_listening }
end

describe port(443) do
  it { should be_listening }
end

describe file('/var/www/vhosts') do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 775 }
  its(:selinux_label) { should eq 'system_u:object_r:httpd_sys_content_t' }
end

[
  '/var/www/vhosts/' + ENV[HOSTNAME],
  '/var/www/vhosts/' + ENV[HOSTNAME] + '/backups',
  '/var/www/vhosts/' + ENV[HOSTNAME] + '/httpdocs',
  '/var/www/vhosts/' + ENV[HOSTNAME] + '/logs',
  '/var/www/vhosts/' + ENV[HOSTNAME] + '/private',
  '/var/www/vhosts/' + ENV[HOSTNAME] + '/subdomains',
  '/var/www/vhosts/subdomain.' + ENV[HOSTNAME],
  '/var/www/vhosts/subdomain.' + ENV[HOSTNAME] + '/backups',
  '/var/www/vhosts/subdomain.' + ENV[HOSTNAME] + '/httpdocs',
  '/var/www/vhosts/subdomain.' + ENV[HOSTNAME] + '/logs',
  '/var/www/vhosts/subdomain.' + ENV[HOSTNAME] + '/private',
  '/var/www/vhosts/subdomain.' + ENV[HOSTNAME] + '/subdomains',
].each do |vhostdir|
  describe file(vhostdir) do
    it { should exist }
    it { should be_directory }
    it { should be_owned_by 'apache' }
    it { should be_grouped_into 'apache' }
    it { should be_mode 775 }

    if vhostdir.index(/(httpdocs|subdomains)/) then
      its(:selinux_label) { should eq 'system_u:object_r:httpd_sys_content_t' }
    end

    if vhostdir.index(/(backups|private)/) then
      its(:selinux_label) { should eq 'system_u:object_r:httpd_sys_rw_content_t' }
    end

    if vhostdir.index("logs") then
       its(:selinux_label) { should eq 'system_u:object_r:httpd_log_t' }
    end
  end
end
