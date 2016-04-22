# Seal
[![Build Status](https://travis-ci.org/18F/seal.svg)](https://travis-ci.org/18F/seal)

##What is it?

A Slack bot forked from [binaryberry](https://github.com/binaryberry/seal) that
checks GitHub once a day on weekdays for open pull requests across all repos
belonging to a GitHub organization, and posts them to language-specific Slack
channels, such as `#ruby-pull-requests`. Notifications for individual repos can
also be configured.

The goal is to encourage people to review pull requests in a timely manner, and
by organizing the notifications into language-specific channels, it makes it
easier and less noisy to view pull requests that align with your expertise.

![image](https://github.com/binaryberry/seal/blob/master/images/readme/informative.png)
![image](https://github.com/binaryberry/seal/blob/master/images/readme/angry.png)

##How to use it?

### Main configuration

Create a YAML file named after your GitHub organization, and place it in the
`config` folder. For example, `config/18f.yml`. Create entries for each
language, and specify the Slack channel the bot should post to. For example:

```yaml
ruby:
  channel: '#ruby-pull-requests'
  language: 'ruby'

python:
  channel: '#python-pull-requests'
  language: 'python'
```

In addition to language-based entries, you can also specify a specific repo.
For example, if a team that works on `awesome_repo` wants to integrate Seal
into their Slack channel, they would add the following to the YAML file:

```yaml
awesome-repo:
  channel: '#channel-for-awesome-repo'
  repo: 'awesome-repo'
```

### Customization

Modify `config/global.yml` to suit your needs. You can ignore pull requests
whose title or labels contain certain strings, such as `WIP`. You can also
ignore entire repos. For example:

```yaml
exclude_titles:
  - 'WIP'
  - '[WIP]'

exclude_labels:
  - 'wip'

ignored_repos:
  - 'C2'
```

### Environment variables

Configure the required environment variables. To test the bot locally, you
can set the variables by running the following commands in your Terminal:

```sh
export SEAL_ORGANISATION="your_github_organisation"
export GITHUB_TOKEN="your_github_token_from_your_github_settings"
export SLACK_WEBHOOK="your_incoming_webhook_link_for_your_slack_group_channel"
```

- To get a new `GITHUB_TOKEN`, head to: https://github.com/settings/tokens
- To get a new `SLACK_WEBHOOK`, head to: https://slack.com/services/new/incoming-webhook

  You can configure the webhook with any channel. You'll still be able to post
  to multiple channels.

### Emojis

Set up the following custom emojis in Slack:
- :informative_seal:
- :angrier_seal:
- :seal_of_approval:
- :happyseal:

You can use the images in `images/emoji/Everyday images` that have the corresponding names.

### Test the bot

To test the script locally, go to Slack and create a channel or private group
called `#seal-bot-test`. Then run `./bin/seal.rb` from your command line. You
should see a post in the `#seal-bot-test` channel.

When that works, you can push the app to Heroku, add the `GITHUB_TOKEN` and
`SLACK_WEBHOOK` environment variables to Heroku, and use the [Heroku scheduler
add-on](https://elements.heroku.com/addons/scheduler) to run Seal at the same
time every day, for example at 9:30 every morning (the Seal won't post on
weekends).


## Deploy to Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

##How to run the tests?
Run `rspec` in the command line


Credits
-------

The 18F Seal Slackbot is based on and inspired by
[Tatiana Soukiassian's Seal](https://github.com/binaryberry/seal) Slackbot.

### Public domain

Tatiana Soukiassian's original work remains covered under an
[MIT License](https://github.com/binaryberry/seal/blob/master/LICENCE).

18F's work on this project is in the worldwide [public domain](LICENSE.md), as are contributions to our project. As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
