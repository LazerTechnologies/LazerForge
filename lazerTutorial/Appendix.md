## Useful Aliases

```bash
alias gm="foundryup"
alias fb="forge build"
alias fc="forge clean"
alias ff="forge fmt"
alias ft="forge test -vvv"

reinit() {
    git submodule deinit -f .
    git submodule update --init --recursive
}
```

## Notes

- When experiencing irregular behavior that's difficult to explain, it's worth running `foundryup` and `forge clean` just to make sure that everything's all synced on the latest. See [https://book.getfoundry.sh/reference/forge/forge-clean](https://book.getfoundry.sh/reference/forge/forge-clean) for more.

- It's advisable to run `forge build --watch` while writing a new function to make sure the compiler is happy with your code, especially if the syntax highlighting lags. It's advisable to run `forge test -vvv --watch` while tweaking a test or tweaking code that a test targets. See [https://book.getfoundry.sh/forge/tests#watch-mode](https://book.getfoundry.sh/forge/tests#watch-mode) for more info.

## Additional Resources

- [Understanding Foundry Profiles](profiles.md) - A comprehensive guide to using different Foundry profiles for development, testing, and deployment.
- [Foundry Book](https://book.getfoundry.sh/)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)
- [Solady Contracts](https://github.com/vectorized/solady)
- [Ethereum Development Documentation](https://ethereum.org/en/developers/docs/)

---

**Navigation:**

- [← Back: Profiles](profiles.md)
- [Back to Tutorial Overview →](README.md)
