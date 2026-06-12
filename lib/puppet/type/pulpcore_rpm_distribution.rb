# frozen_string_literal: true

Puppet::Type.newtype(:pulpcore_rpm_distribution) do
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

  newproperty(:base_path) do
    newvalue(%r{\A.+\z})
  end

  newproperty(:repo) do
    desc 'The name of the repository to be used for auto-distributing.  Set to `absent` to remove.'

    newvalue(:absent)
    newvalue(%r{\A.+\z})
  end

  newproperty(:checkpoint) do
    desc 'Whether this distribution should host `checkpoint` publications or not.'

    munge { |value| @resource.munge_boolean_to_symbol(value) }
  end

  autorequire(:pulpcore_rpm_repo) do
    if self[:repo] && self[:repo] != :absent
      [self[:repo]]
    else
      []
    end
  end
end
