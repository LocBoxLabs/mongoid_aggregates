module Mongoid
  module Contextual
    module Aggregable
      module Commands
        class Project < Base
          def initialize(*args)
            super('$project', *args)
          end
        end
      end
    end
  end
end

