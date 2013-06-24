module Mongoid
  module Contextual
    module Aggregable
      module Commands
        class Group < Base
          def initialize(key, *args)
            super('$group', *args.unshift({'_id' => normalize_id(key)}))
          end
        end
      end
    end
  end
end

