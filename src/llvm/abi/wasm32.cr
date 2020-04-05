require "../abi"

class LLVM::ABI::Wasm32 < LLVM::ABI
  def abi_info(atys : Array(Type), rty : Type, ret_def : Bool, context : Context)
    ret_ty = compute_return_type(rty, ret_def, context)
    arg_tys = compute_arg_types(atys, context)
    FunctionType.new(arg_tys, ret_ty)
  end

  def size(type : Type)
    target_data.abi_size(type).to_i32
  end

  def align(type : Type)
    target_data.abi_alignment(type).to_i32
  end

  private def compute_return_type(rty, ret_def, context)
    if rty.aggregate?
      ArgType.indirect(rty, LLVM::Attribute::ByVal)
    else
      ArgType.direct(rty)
    end
  end

  private def compute_arg_types(atys, context)
    atys.map do |t|
      if t.aggregate?
        ArgType.indirect(t, LLVM::Attribute::ByVal)
      else
        ArgType.direct(t)
      end
    end
  end
end
