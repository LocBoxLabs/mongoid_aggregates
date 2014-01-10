require_relative "commands/base"
require_relative "commands/match"
require_relative "commands/group"
require_relative "commands/sort"
require_relative "commands/project"
require_relative "commands/limit"

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

        def project(*args)
          @commands.push(Commands::Project.new(*args))
          self
        end

        def sort(*args)
          @commands.push(Commands::Sort.new(*args))
          self
        end

        def or(*args)
          @commands.push(Commands::Or.new(*args))
          self
        end

        def limit(*args)
          @commands.push(Commands::Limit.new(*args))
          self
        end

        def explain
          @commands.to_json
        end

        def sum(field)
          all.inject(0) {
              |sum, item| sum + (item[field.to_s] || 0)
          }
        end

        def compute(field)
          res = all.inject(Hash.new 0) {
              |compute, item| compute[:count] += 1; compute[:sum] += item["#{field}"] unless item["#{field}"].nil?; compute
          }
          res[:avg] = res[:sum] / (res[:count] != 0 ? res[:count] : 1 )
          res
        end

        def count
          all.count
        end

        protected

        def method_missing(name, *args, &block)
          if @context.scopes.has_key?(name)
            criteria = @context.scopes[name][:scope].call(*args)
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


