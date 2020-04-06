{% skip_file unless flag?(:wasm64) && !flag?(:wasi) %}

class Fiber
  # :nodoc:
  def makecontext(stack_ptr, fiber_main) : Nil
    # TODO: Determine if this is correct for wasm64
    #
    # in x86-64, the context switch push/pop 6 registers + the return address
    # that is left on the stack, we thus reserve space for 7 pointers:
    @context.stack_top = (stack_ptr - 7).as(Void*)
    @context.resumable = 1

    stack_ptr[0] = fiber_main.pointer # %rbx: initial `resume` will `ret` to this address
    stack_ptr[-1] = self.as(Void*)    # %rdi: puts `self` as first argument for `fiber_main`

    # TODO: emscripten_fiber_init
  end

  # :nodoc:
  def self.swapcontext(current_context, new_context) : Nil
    # TODO: emscripten_fiber_swap
  end
end
