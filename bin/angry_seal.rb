#!/usr/bin/env ruby

require 'yaml'
require "./lib/github_fetcher.rb"
require "./lib/message_builder.rb"
require "./lib/slack_poster.rb"

CONFIG = YAML.load_file( "./config/config.yml" )[ARGV[0]]

git = GithubFetcher.new(CONFIG["members"],CONFIG["repos"])

list = git.list_pull_requests

message_builder = MessageBuilder.new(list, "angry")

message = message_builder.angry

slack = SlackPoster.new(ENV["SLACK_WEBHOOK"], CONFIG["channel"], "angry")

slack.send_request(message)