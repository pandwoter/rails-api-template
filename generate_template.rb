# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

Bundler.require(:default, :development)
class RailsNotInstalledError < StandardError; end
class UnknownDatabase < StandardError; end

module ApiTemplate
  module Cli
    module Commands
      extend Dry::CLI::Registry

      # Simple placeholder for version
      class Version < Dry::CLI::Command
        desc 'Print version'.colorize :blue

        def call(*)
          puts '0.0.1'.colorize :blue
        end
      end

      # Generate Template command with many amazing options!
      class GenerateApiTemplate < Dry::CLI::Command
        desc 'Generates ready for use API template'.colorize :blue

        argument :app_name,          required: true,  desc: 'Application name'
        argument :database,          required: true,  desc: 'Application DB (sqlite if not specified)'
        argument :solargraph,        required: false, desc: 'Create solargraph config?'
        argument :rubocop,           required: false, desc: 'Create rubocop config?'
        argument :pryrc,             required: false, desc: 'Create pryrc custom config?'
        argument :rspec,             required: false, desc: 'Configure RSpec?'
        argument :jwt_auth_template, required: false, desc: 'Scaffolds jwt-auth'

        def call(**options)
          puts '[API generation] started!'.colorize :green
          extend FileUtils

          puts '[API generation] checking rails installation'.colorize :green
          raise RailsNotInstalledError unless `gem list` =~ /rails/

          puts '[API generation] creating rails folder'.colorize :green
          raise UnknownDatabase unless %w{mysql postgresql sqlite}.include? options[:database]
          system("rails new #{options[:app_name]} --api --database=#{options[:database]}")

          puts '[API generation] rails folder has been created'.colorize :green

          puts '[API generation] Copying Gemfile'.colorize :green
          puts '[API generation] Copying Solargraph config'.colorize :green
          puts '[API generation] Copying Rubocop config'.colorize :green
          puts '[API generation] Copying Pryrc config'.colorize :green
          puts '[API generation] Copying RSpec config'.colorize :green
          puts '[API generation] Bootstraping simple jwt auth'.colorize :green
        end
      end

      register 'version',  Version,             aliases: ['v', '-v', '--version']
      register 'generate', GenerateApiTemplate, aliases: ['g', '-g', '--generate'] 
    end
  end
end

Dry::CLI.new(ApiTemplate::Cli::Commands).call
