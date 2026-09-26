#!/bin/sh
# Compiles env's C runtime on its own (no bats, no ATS2) and checks
# _env_args against the real argv and _env_cwd against getcwd. It runs on every OS in CI, including
# ones where bats cannot run yet.
#
# usage: tests/c/run.sh   (needs cc)
set -eu
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
sed -n '/^%{#$/,/^%}$/p' "$ROOT/src/lib.bats" | sed '1d;$d' > "$TMP/env_runtime.h"
cat > "$TMP/main.c" <<'C'
#include "env_runtime.h"
#include <stdio.h>
int main(int argc, char **argv) {
  char want[256], got[256], small[4];
  int i, n = 0, k, ks;
  for (i = 0; i < argc; i++) {
    int len = (int)strlen(argv[i]) + 1;
    memcpy(want + n, argv[i], (size_t)len);
    n += len;
  }
  k = _env_args(got, (int)sizeof got);
  ks = _env_args(small, 4);
  if (k != n || memcmp(got, want, (size_t)n) != 0) {
    printf("FAIL args: got %d bytes, want %d\n", k, n);
    return 1;
  }
  if (ks != 4 || memcmp(small, want, 4) != 0) {
    printf("FAIL truncated: got %d bytes\n", ks);
    return 1;
  }
  printf("ok   c-args\n");
  {
    char c1[4096], c2[4096];
    int kc = _env_cwd(c1, (int)sizeof c1);
    if (!getcwd(c2, sizeof c2) || kc != (int)strlen(c2) || memcmp(c1, c2, (size_t)kc) != 0) {
      printf("FAIL cwd: got %d bytes\n", kc);
      return 1;
    }
  }
  printf("ok   c-cwd\n");
  return 0;
}
C
cc -o "$TMP/t" "$TMP/main.c"
"$TMP/t" one "two three" ""
