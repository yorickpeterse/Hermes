require File.expand_path('../../../helper', __FILE__)

describe 'Hermes::Helper::URL' do
  extend Hermes::Helper::URL

  it 'Retrieve teh title of a website' do
    url_title('http://simple.com').should == 'This is the title of a website'
  end
end
