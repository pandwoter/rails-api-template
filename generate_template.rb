# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'yaml'
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
ENV_FILE_PATH = './lib/.env'

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
        argument :database_user,     required: true,  desc: 'Application DB user'
        argument :database_password, required: true,  desc: 'Application DB password'
        argument :solargraph,        required: false, desc: 'Create solargraph config?'
        argument :rubocop,           required: false, desc: 'Create rubocop config?'
        argument :pryrc,             required: false, desc: 'Create pryrc custom config?'
        argument :rspec,             required: false, desc: 'Configure RSpec?'
        argument :jwt_auth_template, required: false, desc: 'Scaffolds jwt-auth'
        argument :git_hooks,         required: false, desc: 'Runs Brakeman, Rspec, Rubocop on commit/push'

        def call(**options)
          extend FileUtils
          extend FileHelper

          LOGGER.info('started!')
          LOGGER.info('checking rails installation')

          raise RailsNotInstalledError unless `gem list` =~ /rails/

          LOGGER.info('setting db-adapter gem')

          unless %w[mysql postgresql sqlite].include? options[:database]
            raise UnknownDatabase
          end

          LOGGER.info('Adding credentials to ENV file')
          File.open(ENV_FILE_PATH, 'a') do |f|
            f.puts '#---dunamic_setted_conntent---'
            f.puts "DB_USER=#{options[:database_user]}"
            f.puts "DB_PASSWORD=#{options[:database_password]}"
          end

          LOGGER.info('creating rails folder')
          system("rails new #{options[:app_name]} --api --database=#{options[:database]}")

          File.open(GEMFILE_PATH, 'a') do |f|
            f.puts '#---dunamic_setted_conntent---'
            f.puts '#db-adapter'
            f.puts APP_DB_MAP[options[:database]]
          end

          if options[:solargraph]
            copy_file_with_logging('./lib/.solargraph.yml', options[:app_name])
          end
          if options[:rubocop]
            copy_file_with_logging('./lib/.rubocop.yml', options[:app_name])
          end
          if options[:pryrc]
            copy_file_with_logging('./lib/.pryrc', options[:app_name])
          end

          if options[:rspec]
            LOGGER.info('Set-up RSpec configuration')
            LOGGER.info('Removing default tests folder')

            rm_r "#{options[:app_name]}/test", force: true
            copy_file_with_logging('./lib/spec',   options[:app_name], recursive: true)
            copy_file_with_logging('./lib/.rspec', options[:app_name])
          end

          if options[:jwt_auth_template]
            LOGGER.info('Bootstraping simple jwt auth')

            File.open(GEMFILE_PATH, 'a') do |f|
              f.puts '#JWT-auth gems'
              f.puts "gem 'bcrypt', '~> 3.1.7'"
              f.puts "gem 'jwt'"
            end

            copy_file_with_logging('./lib/controllers/.', "#{options[:app_name]}/app/controllers", recursive: true)
            copy_file_with_logging('./lib/models/.',      "#{options[:app_name]}/app/models",      recursive: true)
            copy_file_with_logging('./lib/migrations',    "#{options[:app_name]}/db/migrate",      recursive: true)
            copy_file_with_logging('./lib/rails_lib/.',   "#{options[:app_name]}/app/lib",         recursive: true)
            copy_file_with_logging('./lib/config/.',      "#{options[:app_name]}/config",          recursive: true)
          end

          copy_file_with_logging(GEMFILE_PATH, options[:app_name])
          rm "#{options[:app_name]}/Gemfile.lock", force: true

          copy_file_with_logging(ENV_FILE_PATH, options[:app_name])

          LOGGER.info('Cleanning-up generator Gemfile and ENV')
          delete_dunamic_generated_gems(GEMFILE_PATH, ENV_FILE_PATH)

          if options[:git_hooks]
            copy_file_with_logging('./lib/scripts/.',     "#{options[:app_name]}/scripts",         recursive: true)

            cd(options[:app_name]) do
              LOGGER.info('Initializing empty git repo')
              system("git init #{options[:app_name]}")
              system('git add .')
              system('git commit -m "Init commit"')

              LOGGER.info('Making scripts executable')
              system('chmod +x ./scripts/*.bash')
              system('./scripts/install-hooks.bash')
            end

            LOGGER.info('Configure database.yml file')
            config = YAML.load_file("#{options[:app_name]}/config/database.yml")

            config['default']['password'] = "ENV['DB_PASSWORD']"
            config['default']['username'] = "ENV['DB_USER']"

            File.open("#{options[:app_name]}/config/database.yml", 'w') do |file|
              file.write config.to_yaml
            end
          end
        end
      end

      register 'version',  Version,             aliases: ['v', '-v', '--version']
      register 'generate', GenerateApiTemplate, aliases: ['g', '-g', '--generate']
    end
  end
end

Dry::CLI.new(ApiTemplate::Cli::Commands).call
