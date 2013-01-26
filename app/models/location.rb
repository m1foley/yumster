class Location < ActiveRecord::Base
  attr_accessible :description, :latitude, :longitude, :category

  ## Do not run geocoding on every validation
  acts_as_gmappable :process_geocoding => false

  validates :description, presence: true

  validates :latitude, presence: true, :numericality => {
    :greater_than_or_equal_to => -90,
    :less_than_or_equal_to => 90
  }

  validates :longitude, presence: true, :numericality => {
    :greater_than_or_equal_to => -180,
    :less_than_or_equal_to => 180
  }

  validates :category, presence: true
  validates_inclusion_of :category, :in => %w( Plant Dumpster Organization ), :message => "%s is not a valid category"

end
