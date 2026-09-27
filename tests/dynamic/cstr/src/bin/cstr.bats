#include "share/atspre_staload.hats"
#use array as A
#use env as E
#use result as R
#use str as S

(* get_cstr with names that have no NUL: the array holds the name's
   bytes and nothing after them, so getenv must be handed a copy with a
   NUL, not the array (valgrind reports the over-read otherwise). A NUL
   inside the array ends the name. It runs under valgrind: the copy must
   be freed. Exits 1 on a wrong outcome. *)
fn find {nn:pos | nn < 1048576} (name: &(@[char][nn]), nn: int nn): int = let
  val a = $S.from_char_array(name, nn)
  val buf = $A.alloc<byte>(4096)
  val k = (case+ $E.get_cstr(a, nn, buf, 4096) of
    | ~$R.some(k) => k | ~$R.none() => ~1): int
  val () = $A.free<byte>(buf)
  val () = $A.free<byte>(a)
in k end

implement main0 () = let
  (* PATH, set wherever the tests run. *)
  var p = @[char][4]('P', 'A', 'T', 'H')
  (* PATH, then a NUL and bytes past it that are not part of the name. *)
  var q = @[char][7]('P', 'A', 'T', 'H', '\000', 'X', 'Y')
  (* A variable no one sets. *)
  var m = @[char][16]('B', 'A', 'T', 'S', '_', 'N', 'O', '_', 'S', 'U', 'C', 'H', '_', 'V', 'A', 'R')
  val kp = find(p, 4)
  val kq = find(q, 7)
  val km = find(m, 16)
  val ok = kp > 0 && kq = kp && km = ~1
  val () = (if ok then () else println! ("FAIL: PATH ", kp, ", PATH+NUL ", kq, ", missing ", km))
in if ok then () else exit(1) end
