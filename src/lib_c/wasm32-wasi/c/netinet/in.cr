require "../sys/socket"
require "../stdint"

lib LibC
  IPPROTO_IP   =   0
  IPPROTO_ICMP =   1
  IPPROTO_RAW  = 255
  IPPROTO_TCP  =   6
  IPPROTO_UDP  =  17

  alias InPortT = UShort
  alias InAddrT = UInt

  struct InAddr
    s_addr : InAddrT
  end

  struct In6Addr
    s6_addr : StaticArray(UChar, 16)
  end

  struct SockaddrIn
    sin_family : SaFamilyT
    sin_port : InPortT
    sin_addr : InAddr
  end

  struct SockaddrIn6
    sin6_family : SaFamilyT
    sin6_port : InPortT
    sin6_flowinfo : UInt
    sin6_addr : In6Addr
    sin6_scope_id : UInt
  end
end
