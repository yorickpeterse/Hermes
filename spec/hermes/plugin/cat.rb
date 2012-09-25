require File.expand_path('../../../helper', __FILE__)

describe 'Hermes::Plugin::Cat' do
  it "Retrieve the latest cat picture/video from yorick's feed" do
    xml = File.read(File.join(FIXTURES, 'plugin/cat/yorickpeterse.xml'))

    url, title, date = Hermes::Plugin::Cat::Yorickpeterse.parse(xml)

    url.should   == 'http://cat.yorickpeterse.com/images/2012-06-21.jpg'
    title.should == '2012-06-21.jpg'

    date.is_a?(Time).should == true

    date.strftime('%Y-%m-%d').should == '2012-06-21'
  end

  it "Retrieve the latest cat picture/video from katy's feed" do
    xml = File.read(File.join(FIXTURES, 'plugin/cat/katylava.xml'))

    url, title, date = Hermes::Plugin::Cat::Katylava.parse(xml)

    url.should == 'https://lh5.googleusercontent.com/-YEX1XunoceY/' \
      'T-sVG1P-zMI/AAAAAAAACn4/26WsoZ5XL38/DSC_0410.JPG'

    title.should == 'DSC_0410.JPG'

    date.is_a?(Time).should == true

    date.strftime('%Y-%m-%d').should == '2012-06-27'
  end

  it "Retrieve the latest cat picture/video from nirix's feed" do
    xml = File.read(File.join(FIXTURES, 'plugin/cat/nirix.xml'))

    url, title, date = Hermes::Plugin::Cat::Nirix.parse(xml)

    url.should   == 'http://cat.jackpolgar.com/images/IMG_0829.jpg'
    title.should == 'IMG_0829.jpg'

    date.is_a?(Time).should == true

    date.strftime('%Y-%m-%d').should == '2012-09-17'
  end
end
