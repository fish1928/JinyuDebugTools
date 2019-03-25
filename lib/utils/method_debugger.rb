module JinyuDebugTools
  module MethodDebugger
    def self.included(sub_klass)
      sub_klass.class_eval do
        @method_table = {}

        def self.method_added(method_name)
          return if @method_table[method_name]
          @method_table[method_name] = true
          return if method_name.to_s.match(/^____/)

          alias_method "__#{method_name}".to_sym, method_name

          define_method(method_name) do |*method_args, &block|
            puts "jinyu.debug: #{caller[0]} calls #{method_name}, #{method_args}" if !method_name.to_sym.match(/^__/)
            self.send("__#{method_name}".to_sym, *method_args, &block)
          end
        end
      end
    end
  end
end
