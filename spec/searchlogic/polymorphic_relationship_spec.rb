require 'spec_helper'

describe Searchlogic::Conditions::Polymorphic do 
  before(:each) do 
    @james = User.create(:name => "James")
    @ben = User.create(:name=>"Ben")
    @a1 = Audit.create
    @a2 = Audit.create
    @u1 = User.create(:audits => [@a1])
    @u2 = Company.create(:audits => [@a2])
  end

  xit "finds all other users besides partial name" do 
    # find_users = User.name_not_like("am")
    # not_ben = find_users.map(&:name)
    # not_ben.should eq(["Ben"])
  end
end