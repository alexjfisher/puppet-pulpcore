# frozen_string_literal: true

require 'puppet/provider'

# Base provider for logic common to all Pulpcore providers, regardless of the
# concrete implementation used to communicate with Pulp.
class Puppet::Provider::Pulpcore < Puppet::Provider
  def self.mk_property_hash_getters(*property_names)
    property_names.each do |property_name|
      property_name = property_name.to_sym

      define_method(property_name) do
        property_hash_value(property_name)
      end
    end
  end

  def self.resource_api_hashes
    raise Puppet::DevError, "#{self} must implement .resource_api_hashes"
  end

  def self.resource_api_hash(_resource_name)
    raise Puppet::DevError, "#{self} must implement .resource_api_hash"
  end

  def self.resource_properties_from_api_hash(_api_hash)
    raise Puppet::DevError, "#{self} must implement .resource_properties_from_api_hash"
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  def self.instances
    resource_api_hashes.map do |api_hash|
      properties = resource_properties_from_api_hash(api_hash)
      next if properties.empty?

      new(properties)
    end.compact
  end

  def self.resource_properties(resource_name)
    resource_properties_from_api_hash(resource_api_hash(resource_name))
  rescue Puppet::ExecutionFailure => e
    warning "#resource_properties had an error -> #{e.inspect}"
    {}
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    case @property_flush[:ensure]
    when :absent
      delete_resource
      @property_hash = {}
    when :present
      create_resource
      update_property_hash
    else
      update_resource
      update_property_hash
    end

    @property_flush.clear
  end

  def update_property_hash
    @property_hash = self.class.resource_properties(resource[:name])
  end

  def create_resource
    raise Puppet::DevError, "#{self.class} must implement #create_resource"
  end

  def update_resource
    raise Puppet::DevError, "#{self.class} must implement #update_resource"
  end

  def delete_resource
    raise Puppet::DevError, "#{self.class} must implement #delete_resource"
  end

  private

  def property_hash_value(property_name)
    value = @property_hash[property_name]
    value.nil? ? :absent : value
  end
end
