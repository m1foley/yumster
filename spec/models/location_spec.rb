require 'spec_helper'

describe Location do
  before do
    @user = FactoryGirl.create(:user)
    @location = @user.locations.build(description: 'test desc', latitude: 10, longitude: 101, category: "Plant")
  end

  subject { @location }

  describe "attributes" do
    it { should respond_to(:description) }
    it { should respond_to(:latitude) }
    it { should respond_to(:longitude) }
    it { should respond_to(:category) }
    it { should respond_to(:notes) }
    its(:user) { should == @user }
    it { should respond_to(:latin_name) }
  end

  it "should have the proper values" do
    @location.description.should == 'test desc'
    @location.latitude.should == 10
    @location.longitude.should == 101
    @location.category.should == 'Plant'
    @location.user_id.should == @user.id
  end

  describe "when description is not present" do
    before { @location.description = " " }
    it { should_not be_valid }
  end

  describe "when latitude and longitude are not present" do
    before do
      @location.latitude = nil
      @location.longitude = nil
    end
    it { should_not be_valid }
  end

  describe "latitude and longitude value" do

    describe "with a valid lat/long pair" do
      before do
        @location.latitude = 5
        @location.longitude = -5
      end
      it { should be_valid }
    end
    describe "with an invalid latitude" do
      before do
        @location.latitude = -91
        @location.longitude = -5
      end
      it { should_not be_valid }
    end
    describe "with an invalid longitude" do
      before do
        @location.latitude = 5
        @location.longitude = -181
      end
      it { should_not be_valid }
    end
  end

  describe "when category is not present" do
    before do
      @location.category = nil
    end
    it { should_not be_valid }
  end

  describe "category value" do
    describe "with a valid category" do
      before do
        @location.category = 'Dumpster'
      end
      it { should be_valid }
    end
    describe "with an invalid category" do
      before do
        @location.category = 'Hotdog Stand'
      end
      it { should_not be_valid }
    end
  end

  describe "geocoding gem" do
    it { should respond_to(:distance_to) }
  end

  describe "access to user_id" do
    it "should not allow access" do
      expect do
        Location.new(user_id: 1111)
      end.to raise_error
    end
  end
  describe "when user_id is not present" do
    before do
      @location.user_id = nil
    end
    it { should be_valid }
  end

  describe "description length" do
    it "should be more than four characters" do
      @location.description = "four"
      @location.should_not be_valid
      @location.description = "fiive"
      @location.should be_valid
    end
    it "should be less than 46 characters" do
      @location.description = "this is a string of 46 characters............."
      @location.should_not be_valid
      @location.description = "this is a string of 45 characters............"
      @location.should be_valid
    end
  end

  describe "reverse geolocation" do
    it { should respond_to(:address) }
    it { should respond_to(:street) }
    it { should respond_to(:neighborhood) }
    it { should respond_to(:city) }
    it { should respond_to(:state) }
    it { should respond_to(:state_code) }
    it { should respond_to(:postal_code) }
    it { should respond_to(:country) }
    it { should respond_to(:country_code) }
    context "upon reverse geolocating"do
      before do
        firstresult = {
          'address' => 'aaa_address',
          'city' => 'aaa_city',
          'state' => 'aaa_state',
          'state_code' => 'aaa_state_code',
          'postal_code' => 'aaa_postal_code',
          'country' => 'aaa_country',
          'country_code' => 'aaa_country_code'
        }
        Geocoder.configure(:lookup => :test)
        Geocoder::Lookup::Test.add_stub(
          [10.0, 101.0],
          [firstresult, {'check' => 'nope'}]
        )
        @location.reverse_geocode()
      end
      it "sets the fields" do
        ## FIXME: Figure out how to test address_components_of_type
        @location.address.should == 'aaa_address' 
        @location.city.should == 'aaa_city'
        @location.state.should == 'aaa_state'
        @location.state_code.should == 'aaa_state_code'
        @location.postal_code.should == 'aaa_postal_code'
        @location.country.should == 'aaa_country'
        @location.country_code.should == 'aaa_country_code'
      end
    end
  end

  describe "Location.find_near(latitude, longitude, box_width)" do
    context "with several entries" do
      before do
        location1 = FactoryGirl.create :location, description: "Le Bus Stop", latitude: 47.6202762479463, longitude: -122.303993513106, user_id: 12
        location2 = FactoryGirl.create :location, description: "el portal", latitude: 47.6196396566275, longitude: -122.302057587033, user_id: 12
        location3 = FactoryGirl.create :location, description: "Mac counter at macy's", latitude: 37.7869744260011, longitude: -122.406910526459, user_id: 12
        @locations = Location.find_near('47.6187812537455', '-122.302367052115', Location::NEARBY_DISTANCE_MI * 2)
        @json = @locations.to_json
      end
      it "contains nearby locations but not far away ones" do
        @json.should =~ /Le Bus Stop/
        @json.should =~ /el portal/
        @json.should_not =~ /Mac counter at macy's/
      end
    end
    context "when the location is not approved" do
      before do
        location2 = FactoryGirl.create :location, description: "el portal", latitude: 47.6196396566275, longitude: -122.302057587033, user_id: 12
        location4 = FactoryGirl.create :location, description: "portal dos", latitude: 47.6196396566275, longitude: -122.302057587033, user_id: 12
        location4.approved = false
        location4.save
        @locations = Location.find_near('47.6187812537455', '-122.302367052115', Location::NEARBY_DISTANCE_MI * 2)
        @json = @locations.to_json
      end
      it "should not contain that location" do
        @json.should =~ /el portal/
        @json.should_not =~ /portal dos/
      end
    end
    context "with more than a thousand entries" do
      before do
        locations = []
        locations.stub(:count).and_return 1001
        Location.stub(:within_bounding_box).and_return locations
      end
      it "raises an error" do
        expect {
          Location.find_near('47.6187812537455', '-122.302367052115', Location::NEARBY_DISTANCE_MI * 2)
        }.to raise_error
      end
    end
  end

  describe "Location.deg_to_mi" do
    it "converts degrees to miles" do
      miles = Location.deg_to_mi(1)
      miles.should == Location::MILES_IN_A_DEGREE
    end
  end

  describe "unapproved locations finder" do
    before do
      @location1 = FactoryGirl.create :location
      @location1.approved = false
      @location1.save
      @location2 = FactoryGirl.create :location
      @location2.approved = true
      @location2.save
    end
    it "returns only unapproved locations" do
      check = Location.find_unapproved
      check.should include(@location1)
      check.should_not include(@location2)
    end
  end

  describe "setting notes on a location" do
    before do
      @ipsum = """Lorem ipsum dolor sit amet, consectetur adipisicing elit,
      sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut
      enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi
      ut aliquip ex ea commodo consequat. Duis aute irure dolor in
      reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
      pariatur. Excepteur sint occaecat cupidatat non proident, sunt in
      culpa qui officia deserunt mollit anim id est laborum."""
      loc = FactoryGirl.create :location
      loc.notes = @ipsum
      loc.save
    end
    it "should store the notes correctly" do
      loc = Location.find :last
      loc.notes.should == @ipsum
    end
  end

  describe "which is imported" do
    before do
      @record = FactoryGirl.create :record
      imported = FactoryGirl.create :location
      @record.location = imported
      @record.save
      imported.save
    end
    it "should refer back to its import record" do
      imported = Location.find :last
      imported.record.should == @record
    end
  end

end
