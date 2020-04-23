require "c/dirent"

module Crystal::System::Dir
  def self.open(path : String) : LibC::DIR*
    dir = LibC.opendir(path.check_no_null_byte)
    raise ::File::Error.from_errno("Error opening directory", file: path) unless dir
    dir
  end

  def self.next_entry(dir, path) : Entry?
    # LibC.readdir returns NULL and sets errno for failure or returns NULL for EOF but leaves errno as is.
    # This means we need to reset `Errno` before calling `readdir`.
    Errno.value = Errno::NONE
    if entry = LibC.readdir(dir)
      {% if flag?(:wasi) %}
        # Already a pointer on WASI
        name = String.new(entry.value.d_name)
      {% else %}
        name = String.new(entry.value.d_name.to_unsafe)
      {% end %}
      dir = entry.value.d_type == LibC::DT_DIR
      Entry.new(name, dir)
    elsif Errno.value != Errno::NONE
      raise ::File::Error.from_errno("Error reading directory entries", file: path)
    else
      nil
    end
  end

  def self.rewind(dir) : Nil
    LibC.rewinddir(dir)
  end

  def self.close(dir, path) : Nil
    if LibC.closedir(dir) != 0
      raise ::File::Error.from_errno("Error closing directory", file: path)
    end
  end

  def self.current : String
    {% if flag?(:wasi) %}
      # WASM has no current directory
      # TODO(wasi): emulate with a global or something?
      "/"
    {% else %}
      unless dir = LibC.getcwd(nil, 0)
        raise ::File::Error.from_errno("Error getting current directory", file: "./")
      end

      dir_str = String.new(dir)
      LibC.free(dir.as(Void*))
      dir_str
    {% end %}
  end

  def self.current=(path : String)
    if LibC.chdir(path.check_no_null_byte) != 0
      raise ::File::Error.from_errno("Error while changing directory", file: path)
    end

    path
  end

  def self.tempdir
    tmpdir = ENV["TMPDIR"]? || "/tmp"
    tmpdir.rchop(::File::SEPARATOR)
  end

  def self.create(path : String, mode : Int32) : Nil
    if LibC.mkdir(path.check_no_null_byte, mode) == -1
      raise ::File::Error.from_errno("Unable to create directory", file: path)
    end
  end

  def self.delete(path : String) : Nil
    if LibC.rmdir(path.check_no_null_byte) == -1
      raise ::File::Error.from_errno("Unable to remove directory", file: path)
    end
  end
end
