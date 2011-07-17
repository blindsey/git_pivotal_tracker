$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'git_pivotal_tracker'
require 'rspec'
require 'webmock/rspec'

FIXTURES_PATH = File.join(File.dirname(__FILE__), 'fixtures')

RSpec.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

def stub_git_config(opts = {})
  git_options = {
    "pivotal.api-token" => "8a8a8a8",
    "pivotal.project-id" => "123"
  }.merge opts
  Grit::Repo.stub!(:new).and_return mock('Grit::Repo', :config => git_options)
end
