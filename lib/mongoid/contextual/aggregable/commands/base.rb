module Mongoid
  module Contextual
    module Aggregable
      # Contains behaviour for aggregating values in Mongo.
      module Commands
        class Base < Hash
          def initialize(name, *args)
            values = args.inject({}) { |res, hash| res.merge(hash) }
            self[name] = values
          end

          protected
          def normalize_id(key)
            if (key.present?)
              key.to_s =~ /^\$.+/ ? key : "$#{key}"
            else
              'null'
            end
          end
        end
      end
    end
  end
end

