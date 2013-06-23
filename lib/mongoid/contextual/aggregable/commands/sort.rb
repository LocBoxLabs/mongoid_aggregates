module Mongoid
  module Contextual
    module Aggregable
      module Commands
        class Sort < Base
          def initialize(args)
            super('$sort', args)
          end
        end
      end
    end
  end
end

