# frozen_string_literal: true

require 'json'
require 'tempfile'

module Puppet::Provider::PulpcoreCli
  def self.included(provider_class)
    provider_class.commands pulp_binary: '/usr/bin/pulp'
    provider_class.extend(ClassMethods)
  end

  module ClassMethods
    def pulp(*args)
      pulp_binary('--format', 'json', *args)
    end

    def api_hash_by_href(href)
      response = pulp('show', '--href', href)
      JSON.parse(response)
    end
  end

  def pulp(*args)
    self.class.pulp(*args)
  end

  def with_temp_file_arguments(file_arguments)
    tempfiles = []
    command_arguments = []

    begin
      file_arguments.each do |option, content|
        tempfile = Tempfile.new
        tempfile.chmod(0o600)
        tempfile.write(content)
        tempfile.flush

        tempfiles << tempfile
        command_arguments << option << "@#{tempfile.path}"
      end

      yield command_arguments
    ensure
      tempfiles.each(&:close!)
    end
  end
end
