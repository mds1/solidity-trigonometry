# Solidity Trigonometry

Solidity library offering basic trigonometry functions where inputs and outputs are integers.
Inputs are specified in radians scaled by 1e18, and similarly outputs are scaled by 1e18.
Each invocation of the `sin()` and `cos()` functions cost around 1600&ndash;1700 gas (see the `testNoReverts` costs in `.gas-snapshot` for more info).

This implementation is based off the Solidity trigonometry library written by
[Lefteris Karapetsas](https://twitter.com/LefterisJP)
which can be found [here](https://github.com/Sikorkaio/sikorka/blob/e75c91925c914beaedf4841c0336a806f2b5f66d/contracts/trigonometry.sol).
Compared to Lefteris' implementation, this version makes the following changes:
- Uses a 32 bits instead of 16 bits for improved accuracy
- Updated for Solidity 0.8.x
- Various gas optimizations
- Change inputs/outputs to standard trig format (scaled by 1e18) instead of requiring the integer format used by the algorithm

The original implementation by Lefteris is based off Dave Dribin's [trigint](http://www.dribin.org/dave/trigint/) C library,
which in turn is based on an [article](http://web.archive.org/web/20120301144605/http://www.dattalo.com/technical/software/pic/picsine.html) by Scott Dattalo.

## Usage

To use this in a [Foundry](https://github.com/gakonst/foundry/) project, install it with:

```sh
forge install https://github.com/mds1/solidity-trigonometry
```

To use this in a [dapptools](https://github.com/dapphub/dapptools/) project, install it with:

```sh
dapp install https://github.com/mds1/solidity-trigonometry
```

There is currently no npm package, so for projects using npm for package management, such as [Hardhat](https://hardhat.org/) projects, use:

```sh
yarn add https://github.com/mds1/solidity-trigonometry.git
```

## Development

### Setup

This library is developed with [Foundry](https://github.com/dapphub/dapptools/).
If you don't have Foundry installed, run the command below to get `foundryup`, the Foundry toolchain installer:

```
curl -L https://foundry.paradigm.xyz | bash
```

Then in a new terminal session or after reloading your PATH, run it to get the latest `forge` and `cast` binaries:

```
foundryup
```

Advanced ways to use `foundryup` and other documentation can be found in the [foundryup package]([./foundryup/README.md](https://github.com/gakonst/foundry/tree/master/foundryup)).

### Testing

Run tests with `forge test`, and update gas snapshots with `PROPTEST_CASES=10000 forge snapshot`
