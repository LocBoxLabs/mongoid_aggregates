module Mongoid
  module Contextual
    module Aggregable
      module Commands
        class Match < Base
          def initialize(*args)
            super('$match', *args)
          end
        end
      end
    end
  end
end


