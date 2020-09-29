require "./types"
require "../signal"

lib LibC
  WNOHANG = 1

  fun waitpid(pid : Int, stat_loc : Int*, options : Int) : Int
end
