# Rails API template

## So what it does and how to use
It's simple scaffolder for modern rails apis. Just run one command and you will have anything to get into development process quickly. 
![](demo/demo.gif)

## Usage
```console
foo@bar:~$ git clone https://github.com/pandwoter/rails-6-api-template && cd rails-6-api-template
foo@bar:~$ bundler
foo@bar:~$ chmod +x generate_template
foo@bar:~$ ./generate_template generate app postgresql test_db_user password SOLARGRAPH=true RUBOCOP=true PRYRC=true RSPEC=true JWT_AUTH_TEMPLATE=true GIT_HOOKS=true
```

## Arguments
| ARG               | Description                                                                                     | 
| ------------------|:-----------------------------------------------------------------------------------------------:| 
| APP_NAME          | your application name                                                                           | 
| DATABASE          | one of mysql, postgresql, sqlite database                                                       | 
| DATABASE_USER     | DB user (will be placed in .env file)                                                           | 
| DATABASE_PASSWORD | DB password (will be placed in .env file)                                                       |
| SOLARGRAPH        | copy "lib/.solargraph.yml" config                                                               |
| RUBOCOP           | copy "lib/.rubocop.yml" config                                                                  |
| PRYRC             | copy "lib/.pryrc" config                                                                        |
| RSPEC             | copy rspec conf files                                                                           |
| JWT_AUTH_TEMPLATE | simple JWT auth (implementation can be checked in lib/models lib/controllers lib/migration etc) |
| GIT_HOOKS         | initialize git repository in app folder, also git-hooks scripts from "lib/scripts"              |

## Installed gems
* [rack-cors](https://github.com/cyu/rack-cors)
* [rubocop](https://github.com/rubocop-hq/rubocop)
* [rspec-rails](https://github.com/rspec/rspec-rails)
* [database_cleaner](https://github.com/DatabaseCleaner/database_cleaner)
* [factory_bot_rails](https://github.com/thoughtbot/factory_bot_rails)
* [solargraph](https://github.com/castwide/solargraph)
* [brakeman](https://github.com/presidentbeef/brakeman)
* [fastJSONapi](https://github.com/Netflix/fast_jsonapi)
* [swagger](https://github.com/rswag/rswag)

## Stack & Features
* Ruby 2.7.0
* Rails 6.0.2
* Configurated solargraph
* Usefull .pryrc config
* Configurated rubocop
* API mode
* Puma
* Handling CORS
* RSpec testing framework
* Swagger
* fastJSONapi serializer
* Brakeman 
* Git commit/push hooks

## Add Later
- [x] documentation generator
- [x] fast serializer
- [x] git hooks
- [ ] docker image
- [ ] CircleCi pipelines

## Requirements
* Rails 6.0.2
* Ruby 2.7.0
* Any preinstalled DB (which will later use for creating API)
