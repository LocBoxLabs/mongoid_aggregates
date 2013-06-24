class Metadata
  include Mongoid::Document
  include Mongoid::Contextual::Aggregable::Mongo

  field :facebook_demo_last_updated, type: Time
  field :grid_last_updated, type: Time
  field :last_updated, type: Time
  field :last_updated_str, type: String
  field :type, type: String
end