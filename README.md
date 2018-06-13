# servant-nix

Use Nix expressions as request or response bodies in servant applications

![servant](https://raw.githubusercontent.com/haskell-servant/servant/master/servant.png)

## Example

Run the example:

```
cabal new-test
```

It performs a simple roundtrip test for a fixed Nix expression
which is a list of numbers. See the code in `example/Main.hs`.
