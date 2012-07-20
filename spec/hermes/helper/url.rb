require File.expand_path('../../../helper', __FILE__)

describe 'Hermes::Helper::URL' do
  extend Hermes::Helper::URL
  extend WebMock::API

  it 'Retrieve the title of a website' do
    stubbed_response = File.read(File.join(FIXTURES, 'html/simple.html'))
    request_url      = 'http://simple.com/'

    stub_request(:get, request_url) \
      .to_return(:body => stubbed_response)

    url_title('http://simple.com').should == 'This is the title of a website'
  end

  it 'Ignore non HTML websites when retrieving URL titles' do
    stubbed_response = File.read(File.join(FIXTURES, 'html/simple.html'))
    request_url      = 'http://json-example.com/'

    stub_request(:get, request_url) \
      .to_return(
        :body    => stubbed_response,
        :headers => {'Content-Type' => 'application/json'}
    )

    url_title(request_url).should == nil
  end
end
