# Instructions to install dependencies and run the code

We assume that the scheme one is trying to run, is under `/path/to/qsharp/aes`.

## Dependencies

These will be installed as part of the commands in the Environment setup section below.
- dotnet core sdk 2.1+
- qsharp sdk 0.7.1905.3109 (later versions will need changes to the C# code portions)
- iqsharp
- python 3
- python qsharp package
- FileHelpers dotnet package

## Environment setup

The following should work the same on Windows and Linux, with the minor differences noted below.

- get the dotnet core sdk from https://www.microsoft.com/net/download
- install it following the appropriate OS' instructions
- install python 3 (with pip)
- run the following commands in cmd/shell

First install Q# and IQ# support

```
dotnet new -i Microsoft.Quantum.ProjectTemplates
dotnet tool install -g Microsoft.Quantum.IQSharp --version 0.7.1905.3109
```

In theory, on Linux the last command should add `~/.dotnet/tools` to the PATH. Starting a new bash process without rebooting *does not seem to work*, but logging out and in does.
If not, a patch can be to explicitly modify the PATH on demand by running some of the commands as `PATH=$PATH:~/.dotnet/tools command`.

Instead, on Windows, opening a new instance of cmd.exe or PowerShell should be enough.

Get python3 support, will install jupyter (on windows you may want to write `py -m pip` instead of `pip3`)
```
pip3 install qsharp --upgrade
```
On Linux, one may need to log out and in again.

Install iqsharp jupyter support; this may need the Linux PATH overwrite
```
dotnet iqsharp install --user
cd /path/to/qsharp/aes
```

## How to build
```
cd /path/to/qsharp/aes
dotnet build
```

## How to compute cost estimates
```
cd /path/to/qsharp/aes
dotnet run --no-build
```

## How to run tests

### Linux
```
cd /path/to/qsharp/aes
python3 qtests.py -v # on Linux this may need a PATH override
```

### Windows
```
cd /path/to/qsharp/aes
py qtests.py -v
```
Can also use `python` instead of `py` if PATH is not polluted with a version of Python2.7.

### Python GF256 and AES implementation tests

If you want to test the Python implementations of AES or GF256 used to test the Q# implementation, install
```
pip3 install pycryptodome --user
```
and then run
```
cd /path/to/aes
python3 gf256.py -v
python3 aes.py -v
```
