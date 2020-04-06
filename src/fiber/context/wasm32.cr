{% skip_file unless flag?(:wasm32) && !flag?(:wasi) %}

class Fiber
  # :nodoc:
  def makecontext(stack_ptr, fiber_main)
    # TODO: Determine if this is correct for wasm32
    #
    # in IA32 (x86), the context switch push/pop 4 registers, and we need two
    # more to store the argument for `fiber_main` and keep the stack aligned on
    # 16 bytes, we thus reserve space for 6 pointers:
    @context.stack_top = (stack_ptr - 6).as(Void*)
    @context.resumable = 1

    stack_ptr[0] = self.as(Void*)      # first argument passed on the stack
    stack_ptr[-1] = Pointer(Void).null # empty space to keep the stack alignment (16 bytes)
    stack_ptr[-2] = fiber_main.pointer # initial `resume` will `ret` to this address

    # TODO: emscripten_fiber_init
  end

  # :nodoc:
  def self.swapcontext(current_context, new_context) : Nil
    # TODO: emscripten_fiber_swap
  end
end
