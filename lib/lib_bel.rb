module LibBEL

  class << self

    def rubinius?
      defined?(RUBY_ENGINE) && ("rbx" == RUBY_ENGINE)
    end

    # @api_private
    # Determine FFI constant for this ruby engine.
    def find_ffi
      if rubinius?
        if const_defined? "::Rubinius::FFI"
          ::Rubinius::FFI
        elsif const_defined? "::FFI"
          ::FFI
        else
          require "ffi"
          ::FFI
        end
      else # mri, jruby, etc
        require "ffi"
        ::FFI
      end
    end

    # @api_private
    # Extend with the correct ffi implementation.
    def load_ffi
      ffi_module = LibBEL::find_ffi
      extend ffi_module::Library
      ffi_module
    end

    # @api_private
    # Loads the libkyotocabinet shared library.
    def load_libBEL
      ffi_module = find_ffi
      extend ffi_module::Library

      cwd    = File.expand_path(File.dirname(__FILE__))
      gem_so = File.join(cwd, 'libbel.so')
      begin
        ffi_lib gem_so
      rescue LoadError
        begin
          ffi_lib "libbel.so"
        rescue LoadError
          ffi_lib "./libbel.so"
        end
      end
    end
  end

  # Constant holding the FFI module for this ruby engine.
  FFI = LibBEL::load_ffi
  LibBEL::load_libBEL

  # typedef enum bel_token_type
  enum :bel_token_type, [
    :IDENT,   0,
    :STRING,
    :O_PAREN,
    :C_PAREN,
    :COLON,
    :COMMA,
    :SPACES
  ]

  class BelToken < FFI::Struct

    layout :type,      :bel_token_type,
           :pos_start, :int,
           :pos_end,   :int,
           :value,     :pointer

    def type
      self[:type]
    end

    def pos_start
      self[:pos_start]
    end

    def pos_end
      self[:pos_end]
    end

    def value
      self[:value].read_string
    end

    def hash
      [self.type, self.value, self.pos_start, self.pos_end].hash
    end

    def ==(other)
      return false if other == nil
      self.type == other.type && self.value == other.value &&
        self.pos_start == other.pos_start && self.pos_end == other.pos_end
    end

    alias_method :eql?, :'=='
  end

  class BelTokenList < FFI::ManagedStruct
    include Enumerable

    layout :length,    :int,
           :tokens,    BelToken.ptr

    def each
      if block_given?
        iterator = LibBEL::bel_new_token_iterator(self.pointer)
        while LibBEL::bel_token_iterator_end(iterator).zero?
          current_token = LibBEL::bel_token_iterator_get(iterator)
          yield LibBEL::BelToken.new(current_token)
          LibBEL::bel_token_iterator_next(iterator)
        end
        LibBEL::free_bel_token_iterator(iterator)
      else
        enum_for(:each)
      end
    end

    def token_at(position)
      self.each_with_index { |tk, index|
        if (tk.pos_start..tk.pos_end).include? position
          return [tk, index]
        end
      }
      nil
    end

    def self.release(ptr)
      LibBEL::free_bel_token_list(ptr)
    end
  end

  class BelTokenIterator < FFI::ManagedStruct
    include Enumerable

    layout :index,         :int,
           :list,          :pointer,
           :current_token, :pointer

    def each
      if self.null? or not LibBEL::bel_token_iterator_end(self).zero?
        fail StopIteration, "bel_token_iterator reached end"
      end

      if block_given?
        while LibBEL::bel_token_iterator_end(self.pointer).zero?
          current_token = LibBEL::bel_token_iterator_get(self.pointer)
          yield LibBEL::BelToken.new(current_token)
          LibBEL::bel_token_iterator_next(self.pointer)
        end
      else
        enum_for(:each)
      end
    end

    def self.release(ptr)
      LibBEL::free_bel_token_iterator(ptr)
    end
  end

  attach_function :bel_new_token,           [:bel_token_type, :pointer, :pointer, :pointer], :pointer
  attach_function :bel_new_token_list,      [:int                                         ], :pointer
  attach_function :bel_new_token_iterator,  [:pointer                                     ], :pointer
  attach_function :bel_token_iterator_get,  [:pointer                                     ], :pointer
  attach_function :bel_token_iterator_next, [:pointer                                     ], :void
  attach_function :bel_token_iterator_end,  [:pointer                                     ], :int
  attach_function :bel_parse_term,          [:string                                      ], :pointer
  attach_function :bel_tokenize_term,       [:string                                      ], :pointer
  attach_function :bel_print_token,         [:pointer                                     ], :void
  attach_function :bel_print_token_list,    [:pointer                                     ], :void
  attach_function :free_bel_token,          [:pointer                                     ], :void
  attach_function :free_bel_token_list,     [:pointer                                     ], :void
  attach_function :free_bel_token_iterator, [:pointer                                     ], :void

  def self.tokenize_term(string)
    LibBEL::BelTokenList.new(self.bel_tokenize_term(string))
  end

  def self.print_token(token)
    self.bel_print_token(token.pointer)
  end

  def self.print_token_list(list)
    self.bel_print_token_list(list.pointer)
  end
end

