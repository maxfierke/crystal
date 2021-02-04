require "./sys/types"
require "./time"

lib LibC
  SIGHUP    = 1
  SIGINT    = 2
  SIGQUIT   = 3
  SIGILL    = 4
  SIGTRAP   = 5
  SIGIOT    = LibC::SIGABRT
  SIGABRT   =  6
  SIGFPE    =  8
  SIGKILL   =  9
  SIGBUS    =  7
  SIGSEGV   = 11
  SIGSYS    = 31
  SIGPIPE   = 13
  SIGALRM   = 14
  SIGTERM   = 15
  SIGURG    = 23
  SIGSTOP   = 19
  SIGTSTP   = 20
  SIGCONT   = 18
  SIGCHLD   = 17
  SIGTTIN   = 21
  SIGTTOU   = 22
  SIGIO     = 29
  SIGXCPU   = 24
  SIGXFSZ   = 25
  SIGVTALRM = 26
  SIGUSR1   = 10
  SIGUSR2   = 12
  SIGWINCH  = 28
  SIGPWR    = 30
  SIGSTKFLT = 16
  SIGUNUSED = LibC::SIGSYS
  SIGSTKSZ  = 12288

  SIG_SETMASK = 2

  alias SighandlerT = Int ->
  SIG_DFL = SighandlerT.new(Pointer(Void).new(0_u64), Pointer(Void).null)
  SIG_IGN = SighandlerT.new(Pointer(Void).new(1_u64), Pointer(Void).null)

  struct SigsetT
    val : ULong[16] # 128 / sizeof(long)
  end

  SA_ONSTACK = 0x08000000
  SA_SIGINFO = 0x00000004

  struct SiginfoT
    si_signo : Int
    si_errno : Int
    si_code : Int
    __pad0 : Int
    si_addr : Void* # Assuming the sigfault form of siginfo_t
    __pad1 : StaticArray(Int, 20) # __SI_PAD_SIZE (28) - sizeof(void*) (8) = 20
  end

  alias SigactionHandlerT = (Int, SiginfoT*, Void*) ->

  struct Sigaction
    sa_sigaction : SigactionHandlerT
    sa_mask : SigsetT
    sa_flags : Int
    sa_restorer : Void*
  end

  struct StackT
    ss_sp : Void*
    ss_flags : Int
    ss_size : SizeT
  end

  fun kill(x0 : PidT, x1 : Int) : Int
  fun pthread_sigmask(Int, SigsetT*, SigsetT*) : Int
  fun signal(x0 : Int, x1 : Int -> Void) : Int -> Void
  fun sigaction(x0 : Int, x1 : Sigaction*, x2 : Sigaction*) : Int
  fun sigaltstack(x0 : StackT*, x1 : StackT*) : Int
  fun sigemptyset(SigsetT*) : Int
  fun sigfillset(SigsetT*) : Int
  fun sigaddset(SigsetT*, Int) : Int
  fun sigdelset(SigsetT*, Int) : Int
  fun sigismember(SigsetT*, Int) : Int
end
