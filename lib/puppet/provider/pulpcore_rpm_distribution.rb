# frozen_string_literal: true

require_relative 'pulpcore'

# Abstract provider for Pulpcore RPM distribution resources.
#
# This class contains behaviour common to all `pulpcore_rpm_distribution`
# providers. Concrete implementations, such as the `cli` provider, inherit
# from it.
class Puppet::Provider::PulpcoreRpmDistribution < Puppet::Provider::Pulpcore
  mk_property_hash_getters(
    :base_path,
    :repo,
    :checkpoint
  )

  def self.resource_properties_from_api_hash(distribution_properties)
    resource_properties = {
      name: distribution_properties['name'],
      ensure: :present,
      provider: name,

      base_path: distribution_properties['base_path'],
      repo: repo_property(distribution_properties['repository']),
      checkpoint: distribution_properties['checkpoint'] ? :true : :false
    }

    debug "Distribution resource properties: #{resource_properties.inspect}"

    resource_properties
  end

  def self.repo_property(repository_href)
    return :absent if repository_href.nil?

    repo_name_by_href(repository_href)
  end

  def self.repo_name_by_href(href)
    @repo_name_by_href ||= {}

    @repo_name_by_href[href] ||= api_hash_by_href(href)['name']
  end

  def base_path=(value)
    @property_flush[:base_path] = value
  end

  def repo=(value)
    @property_flush[:repo] = if value == :absent
                               ''
                             else
                               value
                             end
  end

  def checkpoint=(value)
    @property_flush[:checkpoint] = value
  end
end
