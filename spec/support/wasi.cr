require "spec"

{% if flag?(:wasi) %}
  def pending_wasi(description = "assert", file = __FILE__, line = __LINE__, end_line = __END_LINE__, &block)
    pending("#{description} [wasi]", file, line, end_line)
  end

  def pending_wasi(*, describe, file = __FILE__, line = __LINE__, end_line = __END_LINE__, &block)
    pending_wasi(describe, file, line, end_line) { }
  end
{% else %}
  def pending_wasi(description = "assert", file = __FILE__, line = __LINE__, end_line = __END_LINE__, &block)
    it(description, file, line, end_line, &block)
  end

  def pending_wasi(*, describe, file = __FILE__, line = __LINE__, end_line = __END_LINE__, &block)
    describe(describe, file, line, end_line, &block)
  end
{% end %}
