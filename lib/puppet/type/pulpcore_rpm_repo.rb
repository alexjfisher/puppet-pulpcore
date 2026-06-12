# frozen_string_literal: true

Puppet::Type.newtype(:pulpcore_rpm_repo) do
  ensurable

  def munge_boolean_to_symbol(value)
    value = value.downcase if value.respond_to? :downcase

    case value
    when true, :true, 'true', :yes, 'yes'
      :true
    when false, :false, 'false', :no, 'no'
      :false
    else
      raise ArgumentError, 'expected a boolean value'
    end
  end

  newparam(:name, namevar: true)

  newproperty(:description) do
    desc 'The description. Set to `absent` to remove the description.'

    newvalue(:absent)
    newvalue(%r{\A.+\z})
  end

  newproperty(:remote) do
    desc 'The name of a remote to configure on this repository.  Set to `absent` to remove.'

    newvalue(:absent)
    newvalue(%r{\A.+\z})
  end

  newproperty(:retain_package_versions) do
    desc 'The maximum number of versions of each package to keep. A value of 0 means "unlimited".'

    newvalue(%r{\A\d+\z})

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:retain_repo_versions) do
    desc 'Specifies how many repository versions will be kept for a repository. Set to `absent` to remove the setting.'

    newvalue(:absent)
    newvalue(%r{\A\d+\z})

    munge do |value|
      case value
      when 'absent', :absent
        :absent
      else
        Integer(value)
      end
    end
  end

  newproperty(:autopublish) do
    desc 'If set to True, Pulp will automatically create publications for new repository versions.'

    munge { |value| @resource.munge_boolean_to_symbol(value) }
  end

  autorequire(:pulpcore_rpm_remote) do
    if self[:remote] && self[:remote] != :absent
      [self[:remote]]
    else
      []
    end
  end
end
