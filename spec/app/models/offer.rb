class Offer
  include Mongoid::Document
  include Mongoid::Contextual::Aggregable::Mongo

  field :offer_id, type: Integer
  field :business_id, type: Integer
  field :date, type: String
  field :type, type: String

  validates_presence_of :business_id, :offer_id

  embeds_one :stats, class_name: 'OfferStats'
  embeds_one :reservations, class_name: 'OfferReservations'

  accepts_nested_attributes_for :stats, :reservations

  scope :for_date, ->(date_str){ where('date' => date_str) }
  scope :with_type, ->(type){ where('type' => type) }
end

class OfferStats
  include Mongoid::Document
  embedded_in :offer

  field :_id, type: String, default: nil
  field :email_delivery, type: Integer
  field :email_open, type: Integer
  field :email_click, type: Integer
  field :email_bounce, type: Integer
  field :text_delivery, type: Integer
  field :facebook_impressions_paid, type: Integer
  field :facebook_impressions_viral, type: Integer
  field :facebook_impressions_organic, type: Integer
  field :facebook_click, type: Integer
  field :facebook_like, type: Integer
  field :facebook_comment, type: Integer
  field :reach, type: Integer
  field :engagement, type: Integer
end

class OfferReservations
  include Mongoid::Document

  field :_id, type: String, default: nil

  embeds_one :daily, class_name: 'ReservationsPeriod'
  embeds_one :monthly, class_name: 'ReservationsPeriod'
  embeds_one :alltime, class_name: 'ReservationsPeriod'
  embedded_in :offer

  accepts_nested_attributes_for :daily, :monthly, :alltime
end

class ReservationsPeriod
  include Mongoid::Document
  embedded_in :offer_reservations

  field :_id, type: String, default: nil
  field :count, type: Integer
  field :email_count, type: Integer
  field :email_percent, type: Float
  field :email_revenue, type: Float
  field :facebook_percent, type: Float
  field :gross_revenue, type: Float
  field :other_percent, type: Float
  field :total_count, type: Integer
  field :total_revenue, type: Float
end