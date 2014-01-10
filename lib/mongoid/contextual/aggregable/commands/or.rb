module Mongoid
  module Contextual
    module Aggregable
      module Commands
        class Or < Base
          def initialize(*args)
            self['$match'] = { '$or' => args }
          end
        end
      end
    end
  end
end

