#include "share/atspre_staload.hats"
#use array as A
#use env as E
#use result as R
#use str as S

(* get finds PATH (set wherever the tests run) and not a variable no one
   sets. It runs under valgrind: get's NUL-terminated copy of the name
   must be freed. Exits 1 on a wrong outcome. *)
fn lookup {nn:pos | nn < 1048576} (name: &(@[char][nn]), nn: int nn): int = let
  val @(f, b) = $A.freeze<byte>($S.from_char_array(name, nn))
  val buf = $A.alloc<byte>(4096)
  val k = (case+ $E.get(b, nn, buf, 4096) of ~$R.some(k) => k | ~$R.none() => ~1): int
  val () = $A.free<byte>(buf)
  val () = $A.drop<byte>(f, b)
  val () = $A.free<byte>($A.thaw<byte>(f))
in k end

implement main0 () = let
  var p = @[char][4]('P', 'A', 'T', 'H')
  var m = @[char][16]('B', 'A', 'T', 'S', '_', 'N', 'O', '_', 'S', 'U', 'C', 'H', '_', 'V', 'A', 'R')
  val kp = lookup(p, 4)
  val km = lookup(m, 16)
  val ok = kp > 0 && km = ~1
  val () = (if ok then () else println! ("FAIL: PATH ", kp, ", missing ", km))
in if ok then () else exit(1) end
