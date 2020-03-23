# frozen_string_literal: true

require 'colorize'
require 'logger'

LOGGER = Logger.new($stdout)
LOGGER.level = Logger::DEBUG
LOGGER.progname = 'API generation'
LOGGER.formatter = proc do |severity, datetime, progname, msg|
  date_format = datetime.strftime('%Y-%m-%d %H:%M:%S')
  if (severity == 'INFO') || (severity == 'WARN')
    "[#{date_format}] #{severity}  (#{progname}): #{msg}\n".colorize :blue
  else
    "[#{date_format}] #{severity} (#{progname}): #{msg}\n".colorize :blue
  end
end
