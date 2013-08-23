module Mongoid
  module Contextual
    module Aggregable
      module Commands
        class Limit < Base
          def initialize(value)
            self['$limit'] = value
          end
        end
      end
    end
  end
end

