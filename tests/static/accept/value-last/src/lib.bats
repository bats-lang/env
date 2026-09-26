#include "share/atspre_staload.hats"
#use array as A
#use env as E
#use result as R

(* The last byte of $HOME, read at index k - 1. get's length is at most
   the buffer size, so index k - 1 is in bounds with no cast, and index
   k may not be. *)
#pub fn home_last_byte (): int

implement home_last_byte () = let
  val nb = $A.alloc<byte>(4)
  val () = $A.set<byte>(nb, 0, $A.int2byte(72))
  val () = $A.set<byte>(nb, 1, $A.int2byte(79))
  val () = $A.set<byte>(nb, 2, $A.int2byte(77))
  val () = $A.set<byte>(nb, 3, $A.int2byte(69))
  val @(fz, bv) = $A.freeze<byte>(nb)
  val buf = $A.alloc<byte>(256)
  val k = (case+ $E.get(bv, 4, buf, 256) of
    | ~$R.some(k) => k
    | ~$R.none() => 0): [k:nat | k <= 256] int k
  val j = (if k > 0 then k - 1 else 0): [j:nat | j < 256] int j
  val b = byte2int0($A.get<byte>(buf, j))
  val () = $A.free<byte>(buf)
  val () = $A.drop<byte>(fz, bv)
  val () = $A.free<byte>($A.thaw<byte>(fz))
in if k > 0 then b else ~1 end
