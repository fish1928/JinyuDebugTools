module JinyuDebugTools
  module MethodDebugger
    def self.included(sub_klass)
      sub_klass.class_eval do
        @@method_table = {}
        @@interested_table = Hash.new{|hash, key| hash[key] = []}

        def self.debug_method(method_name, parameter_name)
          @@interested_table[method_name] << parameter_name
        end

        def self.method_added(method_name)
          return if @@method_table[method_name]
          @@method_table[method_name] = true
          return if method_name.to_s.match(/^____/)

          origin_method = self.instance_method(method_name) 

          parameter_sequence = origin_method.parameters.map(&:last)

          parameter_sequence_map = {}
          (0...parameter_sequence.size).each do |i|
            parameter_sequence_map[i] ||= :class
          end

          if !method_name.match(/^__/) && @@interested_table[method_name]

            parameter_sequence.each_with_index do |parameter_name, index|
              parameter_sequence_map[parameter_name] = index
            end

            @@interested_table[method_name].each do |parameter_name|
              parameter_sequence_map[parameter_sequence_map[parameter_name]] = :to_s
            end
          end

          alias_method "__#{method_name}".to_sym, method_name

          define_method(method_name) do |*method_args, &block|
            # leak closure
            method_args_strs = []
            method_args.each_with_index do |method_arg, index|
              method_args_strs << method_arg.send(parameter_sequence_map[index])
            end

            caller_file = caller[0].split('/').last
            puts "jinyu.debug: #{caller_file} calls #{method_name}, #{method_args_strs}" if !method_name.to_sym.match(/^__/)
            self.send("__#{method_name}".to_sym, *method_args, &block)
          end
        end
      end
    end
  end
end
