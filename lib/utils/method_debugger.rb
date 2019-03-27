module JinyuDebugTools
  module MethodDebugger
    def self.included(sub_klass)
      sub_klass.class_eval do
        @@__debug_log = []
        @@__method_table = Hash.new{|hash, key| hash[key] = {}}

        def self.method_added(method_name)
          return if @@__method_table[self][method_name]
          @@__method_table[self][method_name] = true

          return if method_name.to_s.match(/^__/)
          #p "alias_method #{self}.__#{method_name}, #{method_name}"
          alias_method "__#{method_name}".to_sym, method_name
          self_class = self

          define_method(method_name) do |*method_args, &block|
            caller_file = caller[0].split('/').last
            puts "jinyu.debug: #{caller_file} calls #{method_name}, #{method_args.map(&:class)}"

            # hit 'super' keyword issue, check with https://stackoverflow.com/questions/18448831
						# remove line below
            #self.send("__#{method_name}".to_sym, *method_args, &block)

            self_class.instance_method("__#{method_name}".to_sym).bind(self).call(*method_args, &block)
          end
        end
      end
    end
  end
end
