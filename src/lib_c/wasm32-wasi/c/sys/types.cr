require "../stddef"
require "../stdint"

lib LibC
  alias BlkcntT = LongLong
  alias BlksizeT = Long
  alias ClockT = LongLong
  type ClockidT = Void*
  alias DevT = ULongLong
  alias GidT = UInt
  alias IdT = UInt
  alias InoT = ULongLong
  alias ModeT = UInt
  alias NlinkT = ULongLong
  alias OffT = LongLong
  alias PidT = Int
  alias PthreadAttrT = UChar
  alias PthreadCondT = UChar

  struct PthreadCondattrT
    __attr : UInt
  end

  alias PthreadMutexT = UChar

  struct PthreadMutexattrT
    __attr : UInt
  end

  type PthreadT = Void*
  alias SSizeT = Long
  alias SusecondsT = LongLong
  alias TimeT = LongLong
  alias UidT = UInt
end
