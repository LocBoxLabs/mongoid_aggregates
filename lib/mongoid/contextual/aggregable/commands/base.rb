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
        end
      end
    end
  end
end

