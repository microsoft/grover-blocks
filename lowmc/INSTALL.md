# Instructions to install dependencies and run the code

We assume that the LowMC code is under `/path/to/qsharp/lowmc` and specify when instructions differ.

## Dependencies

These will be installed as part of the commands in the Environment setup section below.
- dotnet core sdk 2.1,
- qsharp sdk 0.7.1905.3109 (later versions will need changes to the C# code portions),
- iqsharp,
- python 3,
- python qsharp package,
- FileHelpers dotnet package,
- SageMath to regenerate the provided affine layers and key expansion routines (if reproducing results).

## Environment setup

The following should work the same on Windows and Linux, with the minor differences noted below.

- Get the dotnet core sdk version 2.1 from https://www.microsoft.com/net/download.
- Install it following the appropriate OS' instructions.
- Install python 3 (with pip and jupyter).
- Run the following commands in cmd/shell.

First install Q# and IQ# support.

```
dotnet new -i Microsoft.Quantum.ProjectTemplates
dotnet tool install -g Microsoft.Quantum.IQSharp --version 0.7.1905.3109
```

In theory, on Linux the last command should add `~/.dotnet/tools` to the PATH. Starting a new bash process without rebooting *does not seem to work*, but logging out and in does.
If not, a patch can be to explicitly modify the PATH on demand by running some of the commands as `PATH=$PATH:~/.dotnet/tools command`.

Instead, on Windows, opening a new instance of cmd.exe or PowerShell should be enough.

Get python3 support (on windows you may want to write `py -m pip` instead of `pip3`).

An implicit dependency to get python3 support is to install Jupyter.
This can be done in many ways, varying from system to system. One conservative and hopefully portable possibility is to run the following.
```
pip3 install jupyter --user
```

We now get the qsharp python package.
NOTE: the difference in qsharp versions is intended.
```
pip3 install qsharp==0.8.1907.1701 --user --upgrade
```
On Linux, one may need to log out and in again for the next command to work.

Install iqsharp jupyter support; this may need a Linux PATH override.
```
dotnet iqsharp install --user
cd /path/to/qsharp/lowmc
```

## How to build

### LowMC AffineLayer and KeyExpansion code generation
Note that compiling all parameter levels takes multiple hours as of now, due to the lack of optimization in the Q# compiler.

#### Generate random matrices from the LowMC spec
Get `generate_matrices.py` from the official repo, and patch it to match the bit ordering used in the LowMC reference C implementation using the following commands.
```
git clone https://github.com/LowMC/lowmc.git
cd lowmc
git checkout e847fb160ad8ca1f373efd91a55b6d67f7deb425
cd ..
patch lowmc/generate_matrices.py -i generate_matrices.patch -o patched.py
```

Then generate the LowMC matrices.
```
python patched.py -b 32 -k 32 -r 10 -o L0.py
python patched.py -b 128 -k 128 -r 20 -o L1.py
python patched.py -b 192 -k 192 -r 30 -o L3.py
python patched.py -b 256 -k 256 -r 38 -o L5.py
```

#### Port the matrices to Q#
Using SageMath, generate Q# code.
```
sage affine_layers.py
sage in_place_round_key_generation.py
```

### Build the Q# code
This step is slow, compilation takes multiple hours.

```
cd /path/to/qsharp/lowmc
dotnet build
```

## How to compute cost estimates
```
cd /path/to/qsharp/lowmc
dotnet run --no-build
```

## How to run tests

Since the compiler is somewhat slow, tests require to modify the Q# Python module.

### Modified Q# for Python

Note: cp and rm may have a different syntax on Windows.
```
git clone https://github.com/microsoft/iqsharp.git
cd iqsharp
git checkout dbcffc3a5709fe0706fe3d44d3145b8b8a4a7ae0
cd ..
cp -r iqsharp/src/Python/qsharp/ .
patch qsharp/clients/__init__.py qsharp_client.patch
rm -rf iqsharp
```

### Linux
On Linux this may need a PATH override.
```
cd /path/to/qsharp/lowmc
python3 qtests.py -v
```

### Windows
```
cd /path/to/qsharp/lowmc
py qtests.py -v
```
One can also use `python` instead of `py` if PATH is not polluted with a version of Python2.7.

## Python LowMC implementation tests

If you want to test the Python implementations of LowMC used to test the Q# implementation, run the following.
```
cd /path/to/lowmc
sage in_place_round_key_generation.py -c 1
python3 lowmc.py -v
```
The test vectors were generated using the reference LowMC C implementation from https://github.com/LowMC/lowmc.
