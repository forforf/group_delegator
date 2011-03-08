require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "GroupDelegator Set Up" do
  it "loads all requires" do
    expect { SourceGroup }.to_not raise_error
    expect { SourceHelper }.to_not raise_error
    expect { GroupDelegatorInstances }.to_not raise_error
    expect { GroupDelegatorKlasses }.to_not raise_error
    expect { GroupDelegator }.to_not raise_error
  end
end

