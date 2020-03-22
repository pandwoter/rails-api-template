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
        desc 'Generates ready for use API'.colorize :blue

        argument :app_name,          required: true,  desc: 'Application name'
        argument :database,          required: true,  desc: 'Application DB (sqlite if not specified)'
        argument :solargraph,        required: false, desc: 'Create solargraph config?'
        argument :rubocop,           required: false, desc: 'Create rubocop config?'
        argument :pryrc,             required: false, desc: 'Create pryrc custom config?'
        argument :rspec,             required: false, desc: 'Configure RSpec?'
        argument :jwt_auth_template, required: false, desc: 'Scaffolds jwt-auth'

        def copy_file_wrapper(src, dest, color)
          puts "Copying #{src} to #{dest}...".colorize(color)
          cp(src, dest)
          puts 'Copied...'.colorize(color)
        end

        def call(**options)
          extend FileUtils
          puts '[API generation] started!'.colorize :green
          puts '[API generation] checking rails installation'.colorize :green
          raise RailsNotInstalledError unless `gem list` =~ /rails/

          puts '[API generation] creating rails folder'.colorize :green
          raise UnknownDatabase unless %w[mysql postgresql sqlite].include? options[:database]

          system("rails new #{options[:app_name]} --api --database=#{options[:database]}")
          puts '[API generation] rails folder has been created'.colorize :green

          copy_file_wrapper('./lib/Gemfile',         "./#{options[:app_name]}", :green)
          rm "./#{options[:app_name]}/Gemfile.lock", force: true
          copy_file_wrapper('./lib/.solargraph.yml', "./#{options[:app_name]}", :green)
          copy_file_wrapper('./lib/.rubocop.yml',    "./#{options[:app_name]}", :green)
          copy_file_wrapper('./lib/.pryrc',          "./#{options[:app_name]}", :green)

          puts '[API generation] Set-up RSpec configuration'.colorize :green
          puts '[API generation] Removing default tests folder'.colorize :green
          rm_r "./#{options[:app_name]}/test", force: true
          cp_r('./lib/spec', "./#{options[:app_name]}")
          copy_file_wrapper('./lib/.rspec', "./#{options[:app_name]}", :green)

          puts '[API generation] Bootstraping simple jwt auth'.colorize :green
        end
      end

      register 'version',  Version,             aliases: ['v', '-v', '--version']
      register 'generate', GenerateApiTemplate, aliases: ['g', '-g', '--generate'] 
    end
  end
end

Dry::CLI.new(ApiTemplate::Cli::Commands).call
