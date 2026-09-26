#include "share/atspre_staload.hats"
#use array as A
#use env as E
#use result as R

(* The harness runs this binary as ./dist/debug/args with no
   arguments, so args_read must give exactly "./dist/debug/args\0",
   and a 4-byte buffer the first 4 of those bytes. *)
fun count_nul {l:agz}{n:pos}{i:nat | i <= n} .<n - i>.
  (b: !$A.arr(byte, l, n), n: int n, i: int i, k: int, acc: int): int =
  if i >= n then acc
  else if i >= k then acc
  else let
    val z = (if byte2int0($A.get<byte>(b, i)) = 0 then 1 else 0): int
  in count_nul(b, n, i + 1, k, acc + z) end

implement main0 () = let
  val buf = $A.alloc<byte>(256)
  val k = (case+ $E.args_read(buf, 256) of | ~$R.some(k) => k | ~$R.none() => 0): [k:nat | k <= 256] int k
  val nuls = count_nul(buf, 256, 0, k, 0)
  val li = (if k >= 1 then k - 1 else 0): [i:nat | i < 256] int i
  val last = byte2int0($A.get<byte>(buf, li))
  val () = $A.free<byte>(buf)
  val small = $A.alloc<byte>(4)
  val ks = (case+ $E.args_read(small, 4) of | ~$R.some(k) => k | ~$R.none() => ~1): int
  val c0 = byte2int0($A.get<byte>(small, 0))
  val () = $A.free<byte>(small)
  (* "./dist/debug/args" is 17 bytes, plus its NUL *)
  val ok = (k = 18) && (nuls = 1) && (last = 0) && (ks = 4) && (c0 = 46)
in
  if ok then println! ("args: all cases pass")
  else let
    val () = println! ("FAIL args: k=", k, " nuls=", nuls, " last=", last, " ks=", ks, " c0=", c0)
  in exit_void(1) end
end
