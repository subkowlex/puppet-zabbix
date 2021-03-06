require File.expand_path(File.join(File.dirname(__FILE__), '..', 'zabbix'))
Puppet::Type.type(:zabbix_application).provide(:ruby, :parent => Puppet::Provider::Zabbix) do

  def connect
    if @resource[:zabbix_url] != ''
      self.class.require_zabbix
    end

    @zbx ||= self.class.create_connection(@resource[:zabbix_url],@resource[:zabbix_user],@resource[:zabbix_pass],@resource[:apache_use_ssl])
    return @zbx
  end

  def template_id
    zbx = connect
    return @template_id ||= zbx.templates.get_id(:host => @resource[:template])
  end

  def create
    zbx = connect
    zbx.applications.create(
      :name   => @resource[:name],
      :hostid => template_id
    )
  end

  def application_id
    zbx = connect
    return @application_id ||= zbx.applications.get_id(:name => @resource[:name])
  end

  def exists?
    zbx = connect
    zbx.applications.get_id(:name => @resource[:name])
  end

  def destroy
    zbx = connect
    begin
        zbx.applications.delete(application_id)
    rescue => error
        raise(Puppet::Error, "Zabbix Application Delete Failed\n#{error.message}")
    end
  end

end
