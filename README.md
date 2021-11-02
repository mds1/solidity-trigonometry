# Solidity Trigonometry

Solidity library offering basic trigonometry functions where inputs and outputs are integers.
Inputs are specified in radians scaled by 1e18, and similarly outputs are scaled by 1e18.
Each invocation of the `sin()` and `cos()` functions cost around 2000&ndash;2500 gas (see `.gas-snapshot`) for more info.

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

To use this in a [dapptools](https://github.com/dapphub/dapptools/) project, install it with:

```sh
dapp install https://github.com/mds1/solidity-trigonometry
```

There is currently no npm package, so for projects using [Hardhat](https://hardhat.org/) or other development frameworks, use:

```sh
yarn add https://github.com/mds1/solidity-trigonometry.git
```

## Development

This library is developed with [dapptools](https://github.com/dapphub/dapptools/).

To update gas snapshots:
1. Install [duppgrade](https://github.com/Rari-Capital/duppgrade)
2. Switch dapptools to the WIP branch with gas snapshot functionality with `duppgrade gas-snapshot-dev`
3. Run `dapp --snapshot`
