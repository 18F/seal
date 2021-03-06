require 'octokit'

class GithubFetcher
  ORGANISATION ||= ENV['SEAL_ORGANISATION']

  def initialize(team_config)
    @github = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
    @github.user.login
    @github.auto_paginate = true
    @team_config = team_config
    @labels = {}
  end

  def list_pull_requests
    pull_requests_from_github.each_with_object({}) do |pull_request, pull_requests|
      repo_name = pull_request.html_url.split("/")[4]
      next if hidden?(pull_request, repo_name)
      pull_requests[pull_request.title] = present_pull_request(pull_request, repo_name)
    end
  end

  private

  attr_reader :team_config

  def global_config
    @global_config ||= YAML.load_file('./config/global.yml')
  end

  def use_labels
    global_config['use_labels']
  end

  def exclude_labels
    return unless global_config['exclude_labels']

    global_config['exclude_labels'].map(&:downcase).uniq
  end

  def exclude_titles
    return unless global_config['exclude_titles']

    global_config['exclude_titles'].map(&:downcase).uniq
  end

  def ignored_repos
    global_config['ignored_repos'] || []
  end

  def language
    team_config['language']
  end

  def repo
    "#{ORGANISATION}/#{team_config['repo']}"
  end

  def present_pull_request(pull_request, repo_name)
    pr = {}
    pr['title'] = pull_request.title
    pr['link'] = pull_request.html_url
    pr['author'] = pull_request.user.login
    pr['repo'] = repo_name
    pr['comments_count'] = count_comments(pull_request, repo_name)
    pr['thumbs_up'] = count_thumbs_up(pull_request, repo_name)
    pr['updated'] = Date.parse(pull_request.updated_at.to_s)
    pr['labels'] = labels(pull_request, repo_name)
    pr
  end

  def pull_requests_from_github
    @github.search_issues(search_parameters).items
  end

  def search_parameters
    if language
      "is:pr state:open user:#{ORGANISATION} language:#{language}"
    elsif repo
      "is:pr state:open repo:#{repo}"
    end
  end

  def count_comments(pull_request, repo)
    pr = @github.pull_request("#{ORGANISATION}/#{repo}", pull_request.number)
    (pr.review_comments + pr.comments).to_s
  end

  def count_thumbs_up(pull_request, repo)
    response = @github.issue_comments("#{ORGANISATION}/#{repo}", pull_request.number)
    comments_string = response.map {|comment| comment.body}.join
    thumbs_up = comments_string.scan(/:\+1:/).count.to_s
  end

  def labels(pull_request, repo)
    return [] unless use_labels
    key = "#{ORGANISATION}/#{repo}/#{pull_request.number}".to_sym
    @labels[key] ||= @github.labels_for_issue("#{ORGANISATION}/#{repo}", pull_request.number)
  end

  def hidden?(pull_request, repo)
    excluded_label?(pull_request, repo) || excluded_title?(pull_request.title) || ignored_repo?(repo)
  end

  def excluded_label?(pull_request, repo)
    return false unless exclude_labels
    lowercase_label_names = labels(pull_request, repo).map { |l| l['name'].downcase }
    exclude_labels.any? { |e| lowercase_label_names.include?(e) }
  end

  def excluded_title?(title)
    exclude_titles && exclude_titles.any? { |t| title.downcase.include?(t) }
  end

  def ignored_repo?(repo)
    ignored_repos.include?(repo)
  end
end
