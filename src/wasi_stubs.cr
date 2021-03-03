# Mostly just copied from win32, with some modifications

struct Exception::CallStack
  def self.skip(*args)
    # do nothing
  end

  def self.print_backtrace
    # do nothing
  end
end

class Process
  INITIAL_PWD = ""

  def self.exit(status = 0)
    LibC.exit(status)
  end

  def self.pid
    1
  end
end
