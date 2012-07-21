require File.expand_path('../../../helper', __FILE__)

describe 'Hermes::Helper::URL' do
  extend Hermes::Helper::URL
  extend WebMock::API

  it 'Retrieve the title of a website' do
    stubbed_response = File.read(File.join(FIXTURES, 'html/simple.html'))
    request_url      = 'http://simple.com/'

    stub_request(:get, request_url).to_return(:body => stubbed_response)

    url_title(request_url).should == 'This is the title of a website'
  end

  it 'Ignore non HTML websites when retrieving URL titles' do
    stubbed_response = File.read(File.join(FIXTURES, 'html/simple.html'))
    request_url      = 'http://json-example.com/'

    stub_request(:get, request_url).to_return(
        :body    => stubbed_response,
        :headers => {'Content-Type' => 'application/json'}
    )

    url_title(request_url).should == nil
  end

  it 'Extract the title of invalid HTML documents' do
    stubbed_response = File.read(File.join(FIXTURES, 'html/invalid.html'))
    request_url      = 'http://invalid.com/'

    stub_request(:get, request_url).to_return(:body => stubbed_response)

    url_title(request_url).should == 'This is the title of a website'
  end

  it 'Extract the title of a Coding Horror page' do
    stubbed_response = File.read(File.join(FIXTURES, 'html/coding_horror.html'))
    request_url      = 'http://codinghorror.com'

    stub_request(:get, request_url).to_return(
      :body    => stubbed_response,
      :headers => {
        'Server'       => 'Apache',
        'X-PhApp'      => 'oak-tp-web013',
        'X-Webserver'  => 'oak-tp-web013',
        'Vary'         => 'cookie',
        'Keep-Alive'   => 'timeout=300, max=100',
        'Content-Type' => 'text/html; charset=utf-8',
        'Date'         => 'Sat, 21 Jul 2012 12:30:50 GMT',
        'X-Varnish'    => '1021627344 1021393271',
        'Age'          => '245',
        'Via'          => '1.1 varnish'
      }
    )

    url_title(request_url).should == 'Coding Horror: New Programming Jargon'
  end
end
