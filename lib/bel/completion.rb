require_relative '../lib_bel'
require_relative 'completion_rule'
require_relative 'language'
require_relative 'namespace'

module BEL
  module Completion

    # Provides completions on BEL expressions.
    #
    # If +bel_expression+ is +nil+ then its assumed to be the empty string
    # otherwise the +to_s+ method is called. An empty +bel_expression+ will
    # return all BEL functions as possible completions.
    #
    # If +search+ is +nil+ then namespace values will not be provided as
    # completion. +search+ is expected to implement {IdentifierSearch}.
    #
    # If +position+ is +nil+ then its assumed to be the last index of
    # +bel_expression+ otherwise the +to_i+ method is called.
    #
    # If +position+ is negative or greater than the length of +bel_expression+
    # an +IndexError+ is raised.
    #
    # @param bel_expression   [responds to #to_s] the bel expression to
    # complete on
    # @param search           [IdentifierSearch ] the search object used to
    # provide namespace value completions
    # @param position         [responds to #to_i] the position to complete from
    # @return [Array<Completion>]
    def self.complete(bel_expression, search = nil, position = nil)
      bel_expression = (bel_expression || '').to_s
      position = (position || bel_expression.length).to_i
      if position < 0 or position > bel_expression.length
        msg = %Q{position #{position}, bel_expression "#{bel_expression}"}
        fail IndexError, msg
      end

      token_list = LibBEL::tokenize_term(bel_expression)
      active_tok, active_index = token_list.token_at(position)

      # no active token indicates the position is out of
      # range of all tokens in the list.
      return [] unless active_tok

      tokens = token_list.to_a
      options = {
        :search => search
      }
      BEL::Completion::rules.reduce([]) { |completions, rule|
        completions.concat(
          rule.apply(tokens, active_tok, active_index, options)
        )
      }
    end
  end
end

