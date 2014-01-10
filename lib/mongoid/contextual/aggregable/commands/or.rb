module Mongoid
  module Contextual
    module Aggregable
      module Commands
        class Or < Base
          def initialize(*args)
            super('$or', *args)
          end
        end
      end
    end
  end
end

