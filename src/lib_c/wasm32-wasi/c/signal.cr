require "./sys/types"
require "./time"

lib LibC
  SIGHUP      = 1_u8
  SIGINT      = 2_u8
  SIGQUIT     = 3_u8
  SIGILL      = 4_u8
  SIGTRAP     = 5_u8
  SIGIOT      = LibC::SIGABRT
  SIGABRT     =  6_u8
  SIGFPE      =  8_u8
  SIGKILL     =  9_u8
  SIGBUS      =  7_u8
  SIGSEGV     = 11_u8
  SIGSYS      = 30_u8
  SIGPIPE     = 13_u8
  SIGALRM     = 14_u8
  SIGTERM     = 15_u8
  SIGURG      = 22_u8
  SIGSTOP     = 18_u8
  SIGTSTP     = 19_u8
  SIGCONT     = 17_u8
  SIGCHLD     = 16_u8
  SIGTTIN     = 20_u8
  SIGTTOU     = 21_u8
  SIGIO       = LibC::SIGPOLL
  SIGXCPU     = 23_u8
  SIGXFSZ     = 24_u8
  SIGVTALRM   = 25_u8
  SIGUSR1     = 10_u8
  SIGUSR2     = 12_u8
  SIGWINCH    = 27_u8
  SIGPWR      = 29_u8
  SIGUNUSED   = LibC::SIGSYS
  SIG_SETMASK = 2

  alias SigsetT = UChar

  fun pthread_sigmask(x0 : Int, x1 : SigsetT*, x2 : SigsetT*) : Int
end
