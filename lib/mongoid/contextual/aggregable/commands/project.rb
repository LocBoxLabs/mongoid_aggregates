module Mongoid
  module Contextual
    module Aggregable
      module Commands
        class Project < Base
          def initialize(*args)
            self['$match'] = { '$or' => args }
          end
        end
      end
    end
  end
end

