require_relative "commands/base"
require_relative "commands/match"
require_relative "commands/group"
require_relative "commands/sort"

module Mongoid
  module Contextual
    module Aggregable
      # Contains behaviour for aggregating values in Mongo.
      class Aggregates
        def initialize(context)
          @context = context
          @commands = []
        end

        def all
          @context.collection.aggregate(@commands)
        end

        def group(key, *args)
          @commands.push(Commands::Group.new(key, *args))
          self
        end

        def sort(*args)
          @commands.push(Commands::Sort.new(*args))
          self
        end

        def explain
          @commands.to_json
        end

        def sum(field)
          all.inject(0) {
              |sum, item| sum + item[field.to_s]
          }
        end

        def count
          all.count
        end

        protected

        def method_missing(name, *args, &block)
          if @context.scopes.has_key?(name)
            criteria = @context.scopes[name][:scope].call(args)
            @commands.push(to_match(criteria))
          elsif @context.respond_to?(name)
            criteria = @context.send(name, *args)
            @commands.push(to_match(criteria))
          else
            raise Errors::UnknownAttribute.new(@context, name)
          end
          self
        end

        def to_match(criteria)
          hash = criteria.selector.inject({}) {|hash, (key, val)| hash[key] = val.is_a?(Array) ? val[0] : val; hash}
          Commands::Match.new(hash)
        end
      end
    end
  end
end


