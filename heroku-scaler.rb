#!/usr/bin/env ruby

require "bundler"
require "optparse"

Bundler.require(:default)

heroku_api_key = ENV["HEROKU_API_KEY"] || raise("No Heroku API key env variable set")
mandrill_api_key = ENV["MANDRILL_APIKEY"] || raise("No Mandrill API key env variable set")
error_email = ENV["ERROR_REPORT_EMAIL"] || raise("No error report email env variable set")
stathat_key = ENV["STATHAT_KEY"]

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{ARGV[0]} [options]"
  opts.on("-a", "--app NAME") { |v| options[:app] = v }
  opts.on("-t", "--type DYNO_TYPE") { |v| options[:type] = v }
  opts.on("-d", "--dynos NO_DYNOS") { |v| options[:count] = v }
end.parse!

raise OptionParser::MissingArgument, "--app" if options[:app].nil?
raise OptionParser::MissingArgument, "--type" if options[:type].nil?
raise OptionParser::MissingArgument, "--dynos" if options[:count].nil?

heroku = Heroku::API.new(api_key: heroku_api_key)

begin
  heroku.post_ps_scale options[:app], options[:type], options[:count]
  if stathat_key
    StatHat::API.ez_post_count [options[:app], options[:type], options[:count]].join("-"), stathat_key, 1
    sleep 1
  end
rescue Heroku::API::Errors::Error => error
  mandrill = Mailchimp::Mandrill.new(mandrill_api_key)
  mandrill.messages_send(
    message: {
      text: [error.message, error.response.body].join("\n\n"),
      subject: "Error scaling #{options[:app]}:#{options[:type]} to #{options[:count]}",
      from_email: mandrill.users_info["username"],
      from_name: "Scaler",
      to: [{email: error_email, name: ""}]
    }
  )
  exit 1
end
