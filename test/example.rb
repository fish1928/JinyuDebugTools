require 'utils/method_debugger'

class Marry
  include JinyuDebugTools::MethodDebugger

  def get_name(word1, word2)
    puts "Hi this is Marry, I want to say #{word1}, #{word2}"
  end
end

Marry.new.get_name('1','2')
