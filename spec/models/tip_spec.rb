require 'spec_helper'

describe Tip do
  before do
    @user = FactoryGirl.create :user
    @location = @user.locations.create FactoryGirl.attributes_for(:location)
    @tip = @location.tips.create(text: "some text", user_id: @user.id)
  end

  subject { @tip }

  it { should be_valid }

  describe "readonly attributes" do
    it "should successfully return user_id and location_id" do
      @tip.location_id.should be
      @tip.user_id.should be
    end
  end

  describe "when text is not present" do
    before { @tip.text = " " }
    it { should_not be_valid }
  end

  describe "when the same user creates a tip on the same location" do
    before { @tip2 = @location.tips.create(text: "some other text", user_id: @user.id) }
    it "should not be valid" do
      @tip2.should_not be_valid
    end
  end

end
