# frozen_string_literal: true

require_relative 'pulpcore'

class Puppet::Provider::PulpcoreRpmRemote < Puppet::Provider::Pulpcore
  mk_property_hash_getters(
    :url,
    :policy,
    :tls_validation,
    :client_cert,
    :ca_cert
  )

  def self.resource_properties_from_api_hash(remote_properties)
    resource_properties = {
      name: remote_properties['name'],
      ensure: :present,
      provider: name,

      url: remote_properties['url'],
      policy: remote_properties['policy'],
      tls_validation: remote_properties['tls_validation'] ? :true : :false,

      client_cert: remote_properties['client_cert'] || :absent,
      ca_cert: remote_properties['ca_cert'] || :absent,

      # Internal provider state, not a Puppet property.
      client_key_set: hidden_field_set?(remote_properties, 'client_key')
    }

    debug "Remote resource properties: #{resource_properties.inspect}"

    resource_properties
  end

  def self.hidden_field_set?(api_hash, field_name)
    hidden_field = Array(api_hash['hidden_fields']).find do |field|
      field['name'] == field_name
    end

    hidden_field ? hidden_field['is_set'] : false
  end

  def client_key_set?
    @property_hash[:client_key_set] == true
  end

  def url=(value)
    @property_flush[:url] = value
  end

  def policy=(value)
    @property_flush[:policy] = value
  end

  def tls_validation=(value)
    @property_flush[:tls_validation] = value
  end

  def client_cert=(value)
    @property_flush[:client_cert] = if value == :absent
                                      ''
                                    else
                                      value
                                    end
  end

  def ca_cert=(value)
    @property_flush[:ca_cert] = if value == :absent
                                  ''
                                else
                                  value
                                end
  end
end
