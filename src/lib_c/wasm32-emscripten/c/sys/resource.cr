lib LibC
  RUSAGE_SELF     =  0
  RUSAGE_CHILDREN = -1

  struct Rusage
    ru_utime : Timeval
    ru_stime : Timeval
    ru_maxrss : Long
    ru_ixrss : Long
    ru_idrss : Long
    ru_isrss : Long
    ru_minflt : Long
    ru_majflt : Long
    ru_nswap : Long
    ru_inblock : Long
    ru_oublock : Long
    ru_msgsnd : Long
    ru_msgrcv : Long
    ru_nsignals : Long
    ru_nvcsw : Long
    ru_nivcsw : Long
    __reserved : StaticArray(Long, 16)
  end

  fun getrusage(x0 : Int, x1 : Rusage*) : Int
end
