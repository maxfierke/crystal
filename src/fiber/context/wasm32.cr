{% skip_file unless flag?(:wasm32) %}

@[ImportModule("asyncify")]
lib Asyncify
  fun start_unwind(stack_ptr : Void*)
  fun stop_unwind()
  fun start_rewind(stack_ptr : Void*)
  fun stop_rewind()
end

class Fiber
  # :nodoc:
  def makecontext(stack_ptr, fiber_main)
    @context.stack_top = stack_ptr.as(Void*)
    @context.resumable = 1

    Asyncify.start_unwind(@context.stack_top)
  end

  # :nodoc:
  @[NoInline]
  @[Naked]
  def self.swapcontext(current_context, new_context) : Nil
    Asyncify.stop_unwind

    current_ctx = current_context.value
    new_ctx = new_context.value

    current_ctx.resumable = 1
    new_ctx.resumable = 0

    Asyncify.start_rewind(new_ctx.stack_top)
  end
end
