module JinyuDebugTools
  module CodeParser
    class CodeNode
    
      def initialize(name)
        @name = name
        @children = []
      end
    
      def get_name
        @name
      end
    
      def get_parent
        @parent
      end
    
      def set_parent(parent_node)
        @parent = parent_node
      end
    
      def append_child(child_node)
        @children << child_node
      end
    
      def set_level(level)
        @level = level
      end
    
      def get_level
        @level
      end
    
      def get_index
        @index
      end
    
      def set_index(list_index)
        @index = list_index
      end
    
      def to_s
        @name
      end
    
      def to_hash
        children = @children.map(&:to_hash)
        children = nil if children.empty?
        {@name => children}
      end
    
      def delete_child(child_node)
        @children.delete(child_node)
      end
    
    end
    
    
    class CodeTree
    
      ROOT_NAME = 'JiNyUsUpErNoDe'
    
      def initialize
        @root = CodeNode.new(ROOT_NAME).tap { |node| node.set_level(0) }
        @node_level_list = []
        @node_level_list << [@root, @root.get_level]
        @root.set_index(@node_level_list.size - 1)
      end
    
      def add_record(parent_name, child_name)
        parent_node, parent_node_index = _find_parent_with_index(parent_name)
    
        child_level = parent_node.get_level + 1
    
        mistab_nodes = _find_mistab_nodes(parent_node_index, child_level)
        if mistab_nodes.any?
          mistab_nodes.each do |mistab_node|
            mistab_node.set_parent(parent_node)
            @root.delete_child(mistab_node)
            parent_node.append_child(mistab_node)
          end
        end
    
        child_node = CodeNode.new(child_name)
        child_node.set_level(child_level)
        @node_level_list << child_node
        child_node.set_index(@node_level_list.size - 1)
        parent_node.append_child(child_node)
        child_node.set_parent(parent_node)
    
        return child_node, child_node.get_index
      end
    
      def get_reverse_index(index)
        @node_level_list.size - 1 - index
      end
    
      def _find_parent_with_index(parent_name)
        if parent_name == @root.get_name
          return @root, @root.get_index
        end
    
        target_index_reverse = @node_level_list.size - 1
    
        node_level_list_reverse = @node_level_list.reverse
        node_level_list_reverse.each_with_index do |node_level_pair, index|
          node, level = *node_level_pair
    
          if node.get_name == parent_name
            target_index_reverse = index
            break
          end
        end
    
        target_node, target_level = node_level_list_reverse[target_index_reverse]
        target_index = get_reverse_index(target_index_reverse)
    
        if target_node == @root
          target_node, target_index = add_record(@root.get_name, parent_name)
        end
    
        return target_node, target_index
      end
    
      def _find_mistab_nodes(parent_node_index, child_level)
        # ... because, the father node which attached on root directly like new
        # would match this situation, parent is root and level < child_level
        mistab_nodes = @node_level_list[parent_node_index...-1].select do |node, level|
          next false if node.get_parent != @root
          next false if node.get_level >= child_level
          true
        end
    
        return mistab_nodes
      end
    
      def to_hash
        @root.to_hash
      end
    
      def my_pretty_print
        require 'json'
        output =  JSON.pretty_generate(self.to_hash)
        output.gsub!(/[\{\}\[\],:]| null/,'')
        output.gsub!(/^\s+$/,'')
        output.gsub!(/^\n/,'')
      end
    end
  
    def self.parse_logs(log_str)
      logs =log_str.each_line.map(&:chomp)
      records = logs.map {|log| log.split(' ')}
      tree = CodeTree.new
      records.each do |parent_name, child_name|
        tree.add_record(parent_name, child_name)
      end
    
      return tree.my_pretty_print
    end
  end
end
