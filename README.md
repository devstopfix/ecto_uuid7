# Ecto.UUID7

An Ecto type for UUID version 7 strings.

Version 7 identifiers are friendlier to you and to your database when used as
primary keys. Quoting an extension to [RFC4122][rfc]:

> UUID version 7 features a time-ordered value field derived from the widely 
> implemented and well known Unix Epoch timestamp source, the number of 
> milliseconds seconds since midnight 1 Jan 1970 UTC, leap seconds excluded. 
> As well as improved entropy characteristics over versions 1 or 6.

Version 4 identifiers utilize 122 bits of randomness (the other
6 bits are used for versioning) causing records to spread uniformly across
your indexes. Being random they are also indistinguishable. Instead we use 74
bits of randomness per millisecond with the higher bits being time and the 
lower bits being random.

In addition the identifiers can be parameterized per table to add a tag
documenting the source of the identifier as described in the blog post
from Stripe [designing APIs for humans][objectids].

See `Ecto.UUID7` for the options.

Example UUIDs:

| Version | Options                 | UUID                                   |
| ------: | ----------------------- | -------------------------------------- |
| 4       | n/a                     | `c52c41fb-da84-4bd9-9bc6-23ac53fa649d` |
| 4       | n/a                     | `804647b2-6aac-4079-bb85-9bb3dd2b1031` |
| 7       | `[]`                    | `01881b68-69c4-79ac-841d-3f5d3e532ff2` |
| 7       | `[]`                    | `01881b68-69c4-7134-a6bc-97642e5b9a36` |
| 7       | `tag: 0xD0C`            | `01881b74-f303-7d0c-84bc-7933009bfb33` |
| 7       | `tag: 0xFEE`            | `01881b75-cbad-7fee-ad2b-485ad44d639a` |
| 7       | `seq: true`             | `01881b77-b689-7939-8000-3b8290bf1f1b` |
| 7       | `seq: true`             | `01881b77-b689-7a72-8004-2a2f17992a6c` |
| 7       | `seq: true, tag: 0xE55` | `01881b7c-48a7-7e55-80cd-70a62c706a37` |
| 7       | `seq: true, tag: 0xE55` | `01881b7c-48a8-7e55-80d3-c5365d794a63` |


## Installation

Add to your dependencies:

```elixir
{:ecto_uuid7, "~> 1.0.0"}
```

Note this uses the `Ecto` module name and namespace. If there is ever then
then we will rename the module and bump the minor version, or retire the
library if it's functionality is replaced.

## Performance

This library delegates most of the work to the existing `Ecto.UUID` type
which is highly optimized. The performance can be verified by running
the [soak test script](soak.exs) - instructions are inside the script.


[objectids]: https://dev.to/stripe/designing-apis-for-humans-object-ids-3o5a
[rfc]: https://datatracker.ietf.org/doc/html/draft-peabody-dispatch-new-uuid-format#name-uuid-version-7