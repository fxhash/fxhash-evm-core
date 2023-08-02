# Component specifications

> This document is used as a basis to track the specifications of various components.

## Gates

### Passing data through the Gates

Let's say that a path required to go through the following nodes:

- access list
- pricing fixed

In order to pass the gates, the user will provide the following parameters to the access list contract:

- acess list mint parameters
- pricing fixed mint parameters (no parameters for pricing fixed, so enmpty bytes)
- issuer safe_mint_iteration parameters (because pricing fixed calls safe_mint_iteration on the issuer)

The data will be encodes in an array of bytes, as following:

```
[ bytes access_list, bytes 0, bytes safe_mint_iteration ]
```

Then, during the flow of execution, byte parameters will be processed one by one, for each gate they go through:

```
user input:
[ bytes access_list, bytes 0, bytes safe_mint_iteration ]

- gate access list:
  - get access_list
  - pass [bytes 0, bytes safe_mint_iteration] to next gate

- gate pricing fixed
  - get bytes 0
  - call issuer with safe_mint_iteration(bytes safe_mint_iteration)
```
