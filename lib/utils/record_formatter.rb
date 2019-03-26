module JinyuDebugTools
  class RecordFormatter
  
    ELEMENT_MAPPING = {
        :file_name => 1,
        :line_number => 2,
        :from_method => 3,
        :to_method => 4,
        :arguments => 5
    }

		# "abc.rb:123:in `cde!' calls fgh?, [String]"  
    REG = /^(.*?)\.rb\:(\d+)\:in \`([a-zA-Z_0-9 \?\!]*?)\' calls ([a-zA-Z0-9_\?\!]+)\, \[(.*?)\]/
    def self.format_raw_log(raw_log, required_element_names)
  
      raw_log_lines = raw_log.each_line.map(&:chomp)
      p raw_log_lines.first
      raw_log_elements = raw_log_lines.map do |line|
        _, file_name, line_number, from_method, to_method, arguments_str = *REG.match(line)
				# [String, Array]
        arguments = arguments_str.split(', ')
			
				# in block in cde!
        from_method = from_method.split(' ').last

				# the same as match result, ignore the matched sentence
        [nil, file_name, line_number, from_method, to_method, arguments]
      end
  
      result = raw_log_elements.map do |raw_log_element|
        required_element_names.map do |required_element_name|
          raw_log_element[ELEMENT_MAPPING[required_element_name]]
        end
      end
  
      return result
    end
  
    def self.format_raw_log_file(file_name)
      output_file_name = "#{file_name}.record"
      log_raw = File.open(file_name).read
      result = RecordFormatter.format_raw_log(log_raw, [:from_method, :to_method])
      File.open(output_file_name, 'w+') do |file|
        result.each do |line|
          file.puts(line.join(' '))
        end
      end
    end
  end
end
