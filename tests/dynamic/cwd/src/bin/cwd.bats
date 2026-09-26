#include "share/atspre_staload.hats"
#use array as A
#use env as E
#use result as R

(* The harness runs this in a directory named w-cwd, so cwd_read must
   give an absolute path ending in "/w-cwd" (the prefix may differ from
   $PWD where /tmp is a symlink). *)
fn at {l:agz}{i:int} (b: !$A.arr(byte, l, 4096), k: int, i: int i): int =
  if i < 0 then ~1 else if i >= k then ~1 else if i >= 4096 then ~1
  else byte2int0($A.get<byte>(b, i))

implement main0 () = let
  val b = $A.alloc<byte>(4096)
  val k = (case+ $E.cwd_read(b, 4096) of | ~$R.some(k) => k | ~$R.none() => 0): [k:nat | k <= 4096] int k
  (* "/w-cwd" *)
  val c0 = at(b, k, 0)
  val c6 = at(b, k, k - 6) val c5 = at(b, k, k - 5) val c4 = at(b, k, k - 4)
  val c3 = at(b, k, k - 3) val c2 = at(b, k, k - 2) val c1 = at(b, k, k - 1)
  val ok = k > 6 && c0 = 47 && c6 = 47 && c5 = 119 && c4 = 45 && c3 = 99 && c2 = 119 && c1 = 100
  val () = $A.free<byte>(b)
in
  if ok then println! ("cwd: all cases pass")
  else let val () = println! ("FAIL cwd: k=", k) in exit_void(1) end
end
