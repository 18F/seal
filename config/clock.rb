require 'clockwork'
require './lib/seal'

module Clockwork
  every(
    1.day,
    'seal.bot',
    at: '12:30',
    tz: 'America/New_York',
    if: lambda { |t| (1..5).cover?(t.wday) }
  ) do
    Seal.new(nil, nil).bark
  end
end
