require 'utils/method_debugger'

module A
    include JinyuDebugTools::MethodDebugger

  def self.b
    p 'b'
  end

  class << self
    def c
      p 'c'
    end
  end
end

A.b
A.c
