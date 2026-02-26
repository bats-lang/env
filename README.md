# env

Environment variable access for the [Bats](https://github.com/bats-lang) programming language.

## Features

- `get`: read an environment variable into a buffer
- `get_cstr`: read an environment variable as a C string

## Usage

```bats
#use env as E
#use array as A

val buf = $A.alloc<byte>(4096)
val len = $E.get(name_bv, name_len, buf, 4096)
```

## API

See [docs/lib.md](docs/lib.md) for the full API reference.

## Safety

`unsafe = true` — wraps C `getenv()`. Exposes a safe typed API.
