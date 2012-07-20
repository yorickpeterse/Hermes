require File.expand_path('../../lib/hermes', __FILE__)
require 'bacon'
require 'webmock'

Bacon.extend(Bacon::TapOutput)
Bacon.summary_on_exit

FIXTURES = File.expand_path('../fixtures', __FILE__)

# Stub various requests using Webmock.
{
  'http://simple.com' => File.join(FIXTURES, 'html/simple.html')
}.each do |url, fixture|
  WebMock.stub_request(:get, url).to_return(:body => File.read(fixture))
end
