require 'utils/method_debugger'

class BaseDeploy
  include JinyuDebugTools::MethodDebugger

  def initialize(name)
    p "in father's init"
    @name = name
  end
  def in_base
  end
end


class ADeploy < BaseDeploy
  attr_reader :vm

  def initialize
    puts "in son's init"
    super('adeploy')
  end

  def set_vm_name(vm_name)
    @vm = vm_name
  end

  def get_vm_config(vm_name, config_name, haha = 3)
    puts "#{vm_name}, #{config_name}, #{@vm}"
  end

  def in_base
  end


end

ad = ADeploy.new
ad.set_vm_name('jinyu-linux-1')
p ad.vm
ad.in_base
ad.get_vm_config('abc','def')
