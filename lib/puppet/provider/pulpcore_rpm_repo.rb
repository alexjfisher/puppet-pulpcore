# frozen_string_literal: true

require_relative 'pulpcore'

class Puppet::Provider::PulpcoreRpmRepo < Puppet::Provider::Pulpcore
  mk_property_hash_getters(
    :autopublish,
    :description,
    :remote,
    :retain_package_versions,
    :retain_repo_versions
  )

  def self.resource_properties_from_api_hash(repo_properties)
    resource_properties = {
      name: repo_properties['name'],
      ensure: :present,
      provider: name,

      description: repo_properties['description'] || :absent,
      remote: remote_property(repo_properties['remote']),
      retain_package_versions: repo_properties['retain_package_versions'],
      retain_repo_versions: repo_properties['retain_repo_versions'] || :absent,
      autopublish: repo_properties['autopublish'] ? :true : :false
    }

    debug "Repository resource properties: #{resource_properties.inspect}"

    resource_properties
  end

  def self.remote_property(remote_href)
    return :absent if remote_href.nil?

    remote_name_by_href(remote_href)
  end

  def self.remote_name_by_href(href)
    @remote_name_by_href ||= {}

    @remote_name_by_href[href] ||= api_hash_by_href(href)['name']
  end

  def description=(value)
    @property_flush[:description] = if value == :absent
                                      ''
                                    else
                                      value
                                    end
  end

  def remote=(value)
    @property_flush[:remote] = if value == :absent
                                 ''
                               else
                                 value
                               end
  end

  def retain_repo_versions=(value)
    @property_flush[:retain_repo_versions] = if value == :absent
                                               ''
                                             else
                                               value
                                             end
  end

  def retain_package_versions=(value)
    @property_flush[:retain_package_versions] = value
  end

  def autopublish=(value)
    @property_flush[:autopublish] = value
  end
end
