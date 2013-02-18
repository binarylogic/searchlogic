require 'spec_helper'

describe Searchlogic::Conditions::DescendBy do 
  before(:each) do 
    @james = User.create(:name=>"James G", :age => 26, :username => "jvans1"   )
    @ben = User.create(:name=>"James V", :age => 19, :username =>  "jvans" )
    @Tren = User.create(:name=>"James B", :age => 21, :username =>  "jvans" )
    @John = User.create(:name=>"L. James H", :age => 22 , :username =>   "jvans")
    User.create(:name=>"Jon L", :age => 21, :username => "jvans1"  )
  end

  it "chains scopes together" do 
    james = User.name_bw("James").age_gt(20).username_eq("jvans1")
    james.count.should eq(1)
    name = james.map(&:name)
    name.first.should eq("James G")
  end

end