require "./sys/types"

lib LibC
  type DIR = Void

  DT_DIR = 3

  struct Dirent
    d_ino : InoT
    d_type : UChar
    d_name : Char*
  end

  fun closedir(x0 : DIR*) : Int
  fun opendir(x0 : Char*) : DIR*
  fun readdir(x0 : DIR*) : Dirent*
  fun rewinddir(x0 : DIR*) : Void
end
