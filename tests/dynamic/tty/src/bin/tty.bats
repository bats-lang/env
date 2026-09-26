#include "share/atspre_staload.hats"
#use env as E

(* The harness sends this binary's stderr to a file, so
   stderr_is_terminal must be false. *)
implement main0 () =
  if $E.stderr_is_terminal () then let
    val () = println! ("FAIL tty: stderr is not a terminal here")
  in exit_void(1) end
  else println! ("tty: all cases pass")
