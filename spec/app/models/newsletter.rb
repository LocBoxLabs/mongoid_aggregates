class Newsletter
  include Mongoid::Document
  include Mongoid::Contextual::Aggregable::Mongo

  field :newsletter_id, type: Integer
  field :business_id, type: Integer
  field :date, type: String
  field :status, type: String
  field :started_at, type: Date

  validates_presence_of :business_id, :newsletter_id

  scope :with_status, ->(status) { where('status' => status) }
end