# Grover-blocks v1.0
## Grover's algorithm for block cipher key search

The grover-blocks project contains implementations of Grover oracles for exhaustive key search on block ciphers via Grover's quantum search algorithm. Version 1.0 provides oracles for AES and LowMC in the quantum-focused programming language Q# and depends on the Microsoft [Quantum Development Kit](https://www.microsoft.com/en-us/quantum/development-kit). The code can be used to obtain quantum resource estimates for exhaustive key search to inform the post-quantum security assessment of AES and LowMC.

The code was developed by [Microsoft Research](http://research.microsoft.com/) for experimentation purposes.

### Issue with estimating resources

A problem with the ResourcesEstimator functionality in Q# has been found and reported in [Issue #192](https://github.com/microsoft/qsharp-runtime/issues/192). Currently, results may report independent lower bounds on depth and width that may not be simultaneously realizable in a quantum circuit. The Q# team has stated that they are working to resolve this issue.

## Installation instructions
- [`AES`](aes/INSTALL.md)
- [`LowMC`](lowmc/INSTALL.md)

## Contributors
- Fernando Virdia
- Samuel Jaques

## License
Grover-blocks is licensed under the MIT License; see [`License`](LICENSE) for details.

# References
[1] Samuel Jaques, Michael Naehrig, Martin Roetteler, and Fernando Virdia, "Implementing Grover oracles for quantum key search on AES and LowMC".
Preprint available at [`https://eprint.iacr.org/2019/1146`](https://eprint.iacr.org/2019/1146).

# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.


