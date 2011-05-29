# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "types"
require "hash-utils/hash"    # >= 0.1.0

##
# Yet anothet options parser. Very rubyfied declarative 
# definitions support.
#

class YAOP

    ##
    # Holds options currently set for parsing.
    #
    
    @options
    
    ##
    # Stack of option in current settings. Although maybe its holder 
    # rather than stack.
    #
    
    @stack
    
    ##
    # Result struct.
    #
    
    Result = Struct::new(:arguments, :parameters)

    ##
    # Returns command line options.
    #
    # @param [Proc] block arguments declaration
    # @return [OptionsHash] hash with options
    #
    
    def self.get(&block)
        parser = YAOP::new
        parser.instance_eval(&block)
        return parser.result
    end
    
    ##
    # Constructor.
    #
    
    def initialize
        @options = [ ]
        @stack = nil
    end
    
    ##
    # Sets option names. Assigning of the new option names will cause 
    # setting the current one to assigned options.
    #
    # @param [*String] args option names including leading character
    # 
    
    def option(*args)
        if not @stack.nil?
            @options << @stack
        end
        
        __reset_stack
        @stack.options = args.map { |i| i.to_s.to_sym }
    end
    
    alias :options :option
    
    ##
    # Defines type and default value specification for current option.
    #
    # Can be used multiple times as indication, argument receives more 
    # values treated as separated Ruby arguments.
    #
    # @param [Class] type type which can be +Boolean+, +String+ or +Integer+
    # @default [Object] the default value
    #
    
    def type(type, default = nil)
        @stack.types << [type, default]
    end
    
    ##
    # Returns list of arguments and parameters according to definition.
    # @return [YAOP::Result] struct with arguments and parameters
    #
    
    def result
    
        # Commits last stack
        if not @stack.nil?
            @options << @stack
            @stack = nil
        end
        
        # Creates options index
        index = { }
        @options.each do |i|
            i.options.each do |id|
                index[id] = i
            end
        end

        # Parses
        last = nil    # note: it's used below
        ARGV.each do |arg|
            if index.has_key? arg.to_sym
                last = arg.to_sym
                index[last].present = true
            elsif not last.nil?
                index[last].values << arg
            end
        end

        # Converts datatypes
        result = Hash::new { |dict, key| dict[key] = [ ] }

        index.each_pair do |opt, spec|
            spec.types.each_index do |i|
                type, default = spec.types[i]
                value = nil

                case type.hash
                    when Integer.hash
                        value = i < spec.values.length ? spec.values[i].to_i : default
                    when String.hash
                        value = i < spec.values.length ? spec.values[i].to_s : default
                    when Boolean.hash
                        value = spec.present ? true : default
                end
                
                if not value.nil?
                    result[opt] << value
                end
            end
        end

        # Converts single value arguments to single-ones
        result.each_pair do |opt, values|
            if index[opt].types.length == 1
                result[opt] = values.first
            end
        end
        
        # Takes parameters from last argument
        if not last.nil?
            parameters = index[last].values[index[last].types.length..-1]
        end
           
        parameters = [ ] if parameters.nil?
        
        
        return self.class::Result::new(
            result.map_keys! { |k| k.to_s },              # converts keys from symbols back to string
            parameters
        )
        
    end
    
    ##
    # Resets stack.
    #
    
    private
    def __reset_stack
        @stack = __struct::new([], [], [], false)
    end
    
    ##
    # Creates and returns stack struct.
    #
    
    private
    def __struct
        if @struct.nil?
            @struct = Struct::new(:options, :types, :values, :present)
        end
        
        @struct
    end
end

=begin
p YAOP::get {
    option "-s", "--strip"
    type Boolean, false
    
    option "-l", "--level"
    type Integer, 7
    type Integer, 8
}
=end
