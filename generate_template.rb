# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require_relative 'utils/logger'
require_relative 'utils/helpers'

Bundler.require(:default, :development)
class RailsNotInstalledError < StandardError; end
class UnknownDatabase < StandardError; end

APP_DB_MAP = {
  'mysql' => "gem 'mysql2'",
  'postgresql' => "gem 'pg'",
  'sqlite' => "gem 'sqlite3'"
}.freeze

GEMFILE_PATH = './lib/Gemfile'

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

        def copy_file_wrapper(src, dest, recursive: false)
          LOGGER.info("Copying #{src} to #{dest}...")
          send(recursive ? :cp_r : :cp, src, dest)
          LOGGER.info('Copied...')
        end

        def call(**options)
          extend FileUtils
          extend FileHelper

          LOGGER.info('started!')
          LOGGER.info('checking rails installation')

          raise RailsNotInstalledError unless `gem list` =~ /rails/

          LOGGER.info('setting db-adapter gem')
          LOGGER.info('creating rails folder')
          unless %w[mysql postgresql sqlite].include? options[:database]
            raise UnknownDatabase
          end

          system("rails new #{options[:app_name]} --api --database=#{options[:database]}")
          LOGGER.info('rails folder has been created')

          File.open(GEMFILE_PATH, 'a') do |f|
            f.puts '---dunamic_setted_gems---'
            f.puts '#db-adapter'
            f.puts APP_DB_MAP[options[:database]]
          end

          if options[:solargraph]
            copy_file_wrapper('./lib/.solargraph.yml', (options[:app_name]).to_s)
          end
          if options[:rubocop]
            copy_file_wrapper('./lib/.rubocop.yml', (options[:app_name]).to_s)
          end
          if options[:pryrc]
            copy_file_wrapper('./lib/.pryrc', (options[:app_name]).to_s)
          end

          if options[:rspec]
            LOGGER.info('Set-up RSpec configuration')
            LOGGER.info('Removing default tests folder')

            rm_r "#{options[:app_name]}/test", force: true
            copy_file_wrapper('./lib/spec',   (options[:app_name]).to_s, recursive: true)
            copy_file_wrapper('./lib/.rspec', (options[:app_name]).to_s)
          end

          if options[:jwt_auth_template]
            LOGGER.info('Bootstraping simple jwt auth')

            File.open(GEMFILE_PATH, 'a') do |f|
              f.puts '#JWT-auth gems'
              f.puts "gem 'bcrypt', '~> 3.1.7'"
              f.puts "gem 'jwt'"
            end

            copy_file_wrapper('./lib/controllers/.', "#{options[:app_name]}/app/controllers", recursive: true)
            copy_file_wrapper('./lib/models/.',      "#{options[:app_name]}/app/models",      recursive: true)
            copy_file_wrapper('./lib/migrations',    "#{options[:app_name]}/db/migrate",      recursive: true)
            copy_file_wrapper('./lib/rails_lib/.',   "#{options[:app_name]}/app/lib",         recursive: true)
          end

          copy_file_wrapper(GEMFILE_PATH, (options[:app_name]).to_s)
          rm "#{options[:app_name]}/Gemfile.lock", force: true

          LOGGER.info('Cleanning-up generator Gemfile')
          delete_dunamic_generated_gems(GEMFILE_PATH)
        end
      end

      register 'version',  Version,             aliases: ['v', '-v', '--version']
      register 'generate', GenerateApiTemplate, aliases: ['g', '-g', '--generate']
    end
  end
end

Dry::CLI.new(ApiTemplate::Cli::Commands).call
