$:.unshift File.expand_path('../../../lib', __FILE__)
require 'rspec'
require 'image_optim/handler'

describe ImageOptim::Handler do
  it 'should use original as source for first conversion and two temp files for further conversions' do
    original = double(:original)
    original.stub(:temp_path){ fail 'temp_path called unexpectedly' }

    handler = ImageOptim::Handler.new(original)

    original.should_receive(:temp_path).once.and_return(temp_a = double(:temp_a))
    handler.process do |src, dst|
      [src, dst].should eq([original, temp_a]); false
    end
    handler.result.should be_nil

    handler.process do |src, dst|
      [src, dst].should eq([original, temp_a]); true
    end
    handler.result.should eq(temp_a)

    original.should_receive(:temp_path).once.and_return(temp_b = double(:temp_b))
    handler.process do |src, dst|
      [src, dst].should eq([temp_a, temp_b]); false
    end
    handler.result.should eq(temp_a)

    handler.process do |src, dst|
      [src, dst].should eq([temp_a, temp_b]); true
    end
    handler.result.should eq(temp_b)

    handler.process do |src, dst|
      [src, dst].should eq([temp_b, temp_a]); true
    end
    handler.result.should eq(temp_a)

    handler.process do |src, dst|
      [src, dst].should eq([temp_a, temp_b]); true
    end
    handler.result.should eq(temp_b)

    temp_a.should_receive(:unlink).once
    handler.cleanup
    handler.cleanup
  end
end
