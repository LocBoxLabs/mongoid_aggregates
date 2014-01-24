module Mongoid
  module Contextual
    module Aggregable
      module Commands
        class Unwind < Base
          def initialize(field)
            self['$unwind'] = normalize_id(field)
          end
        end
      end
    end
  end
end

