#!/usr/bin/env ruby

require 'yaml'

require './lib/github_fetcher.rb'
require './lib/message_builder.rb'
require './lib/slack_poster.rb'

# Entry point for the Seal!
class Seal
  attr_reader :mode

  def initialize(team, mode = nil)
    check_presence_of_config_file
    @team = team
    @mode = mode
  end

  def bark
    teams.each { |team| bark_at(team) }
  end

  private

  attr_accessor :mood

  def check_presence_of_config_file
    unless File.exist?(configuration_filename)
      raise "#{configuration_filename} is missing!"
    end
  end

  def teams
    if @team.nil? && org_config
      org_config.keys
    else
      [@team]
    end
  end

  def bark_at(team)
    message_builder = MessageBuilder.new(message_for(team), @mode)
    message = message_builder.build
    channel = team_config(team)['channel']
    slack = SlackPoster.new(ENV['SLACK_WEBHOOK'], channel, message_builder.poster_mood)
    slack.send_request(message)
  end

  def org_config
    @org_config ||= YAML.load_file(configuration_filename)
  end

  def configuration_filename
    @configuration_filename ||= "./config/#{ENV['SEAL_ORGANISATION']}.yml"
  end

  def message_for(team)
    config = team_config(team)

    return config['quotes'] if @mode == 'quotes'

    fetch_from_github(config)
  end

  def fetch_from_github(team_config)
    git = GithubFetcher.new(team_config)
    git.list_pull_requests
  end

  def team_config(team)
    org_config[team] if org_config
  end
end
