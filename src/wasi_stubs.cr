# Mostly just copied from win32, with some modifications

struct CallStack
  def self.skip(*args)
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

class Mutex
  enum Protection
    Checked
    Reentrant
    Unchecked
  end

  def initialize(@protection : Protection = :checked)
  end

  def lock
  end

  def unlock
  end

  def synchronize
    lock
    begin
      yield
    ensure
      unlock
    end
  end
end

def sleep(seconds : Number)
  sleep(seconds.seconds)
end

def sleep(time : Time::Span)
  LibC.sleep(time.total_seconds.to_i)
end
