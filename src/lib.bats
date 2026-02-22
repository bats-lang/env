(* env -- safe environment variable access *)
(* Reads env vars into arrays. No mutation of the environment. *)

#include "share/atspre_staload.hats"

#use array as A
#use result as R

(* ============================================================
   C runtime (the entire unsafe surface)
   ============================================================ *)

$UNSAFE begin
%{#
#ifndef _ENV_RUNTIME_DEFINED
#define _ENV_RUNTIME_DEFINED
#include <stdlib.h>
#include <string.h>

static int _env_getenv(const char *name, void *buf, int max_len) {
  const char *val = getenv(name);
  if (!val) return -1;
  int len = (int)strlen(val);
  if (len > max_len) len = max_len;
  memcpy(buf, val, (unsigned int)len);
  return len;
}
#endif
%}
end

(* ============================================================
   Public API
   ============================================================ *)

(* Get an environment variable value into an array.
   name: null-terminated env var name in a borrow
   buf: output array to write value into
   Returns option(int): some(len) if set, none if not set. *)
#pub fn get
  {ln:agz}{nn:pos | nn < 1048576}
  {l:agz}{n:pos}
  (name: !$A.borrow(byte, ln, nn), name_len: int nn,
   buf: !$A.arr(byte, l, n), max_len: int n)
  : $R.option(int)

(* Get env var using a null-terminated array as the name.
   The array must contain a null byte within its bounds.
   buf: output array to write value into.
   Returns option(int): some(len) if set, none if not set. *)
#pub fn get_cstr
  {ln:agz}{nn:pos}
  {l:agz}{n:pos}
  (name: !$A.arr(byte, ln, nn), buf: !$A.arr(byte, l, n), max_len: int n)
  : $R.option(int)

(* ============================================================
   Implementation
   ============================================================ *)

implement get {ln}{nn}{l}{n} (name, name_len, buf, max_len) = let
  (* Build null-terminated name *)
  val cname = $A.alloc<byte>(name_len + 1)
  val () = $A.write_borrow(cname, 0, name, name_len)
  val () = $A.write_byte(cname, name_len, 0)
  val len = $extfcall(int, "_env_getenv",
    $UNSAFE begin $UNSAFE.castvwtp1{ptr}(cname) end,
    $UNSAFE begin $UNSAFE.castvwtp1{ptr}(buf) end,
    max_len)
  val () = $A.free<byte>(cname)
in
  if len >= 0 then $R.some(len)
  else $R.none()
end

implement get_cstr {ln}{nn}{l}{n} (name, buf, max_len) = let
  val len = $extfcall(int, "_env_getenv",
    $UNSAFE begin $UNSAFE.castvwtp1{ptr}(name) end,
    $UNSAFE begin $UNSAFE.castvwtp1{ptr}(buf) end,
    max_len)
in
  if len >= 0 then $R.some(len)
  else $R.none()
end
