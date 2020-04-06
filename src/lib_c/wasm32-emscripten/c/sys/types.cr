require "../stddef"
require "../stdint"

lib LibC
  alias BlkcntT = Int
  alias BlksizeT = Long
  alias ClockT = Long
  alias ClockidT = Int
  alias DevT = UInt
  alias GidT = UInt
  alias IdT = UInt
  alias InoT = ULongLong
  alias ModeT = UInt
  alias NlinkT = ULong
  alias OffT = LongLong
  alias PidT = Int

  union PthreadAttrTU
    __i : StaticArray(Int, 11)
    __vi : StaticArray(Int, 11)
    __s : StaticArray(UInt, 11)
  end

  struct PthreadAttrT
    __u : PthreadAttrTU
  end

  union PthreadCondTU
    __i : StaticArray(Int, 12)
    __vi : StaticArray(Int, 12)
    __p : StaticArray(Void*, 12)
  end

  struct PthreadCondT
    __u : PthreadCondTU
  end

  struct PthreadCondattrT
    __attr : UInt
  end

  union PthreadMutexTU
    __i : StaticArray(Int, 7)
    __vi : StaticArray(Int, 7)
    __p : StaticArray(Void*, 7)
  end

  struct PthreadMutexT
    __u : PthreadMutexTU
  end

  struct PthreadMutexattrT
    __attr : UInt
  end

  type PthreadT = Void*
  alias SSizeT = Long
  alias SusecondsT = Long
  alias TimeT = Long
  alias UidT = UInt
end
