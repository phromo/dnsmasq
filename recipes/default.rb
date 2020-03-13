if platform?('ubuntu') && node['platform_version'] >= '18.04'
  directory '/etc/systemd/system/dnsmasq.service.d'

  file 'Fix systemd-resolved conflict' do
    path '/etc/systemd/system/dnsmasq.service.d/systemd-resolved-fix.conf'
    content %{
[Unit]
After=systemd-resolved.service

[Service]
ExecStartPre=/usr/bin/systemctl stop systemd-resolved.service
ExecStartPost=/usr/bin/systemctl start systemd-resolved.service
%}
  end

  service 'systemd-resolved' do
    action :nothing
  end
end

package 'dnsmasq'
user 'dnsmasq'

include_recipe 'dnsmasq::dns' if node['dnsmasq']['enable_dns']
include_recipe 'dnsmasq::dhcp' if node['dnsmasq']['enable_dhcp']

service 'dnsmasq' do
  action [:enable, :start]
end
