# frozen_string_literal: true

require_relative 'lib/helpers'

PROJECT_PATH = `pwd`.strip
APP_DB_MAP = {
  'mysql' => "gem 'mysql2'",
  'postgresql' => "gem 'pg'",
  'sqlite' => "gem 'sqlite3'"
}.freeze

run 'rm -r ./test'
run 'cp -r ../rails_files/. .'

add_env_creds_to_db(PROJECT_PATH + '/config/database.yml')
if yes?('Add database credentials to .env? [yes/no]')
  db = ask('Which db do you use? [mysql/postgresql/sqlite]')
  db_user = ask('Specify db username: ')
  db_password = ask('Specify db password: ')

  case db
  when 'mysql'
    gem 'mysql2'
  when 'postgresql'
    gem 'pg'
  when 'sqlite'
    gem 'sqlite3'
  end

  file '.env', <<~CONFIG
    DB_USER=#{db_user}
    DB_PASSWORD=#{db_password}
  CONFIG
end

after_bundle do
  run('rubocop -a')
  rails_command('db:create')
  rails_command('db:migrate')

  git :init
  git add: '.'
  git commit: "-a -m 'Initial commit'"
  run 'overcommit --install'

  run 'rails s'
end
