@echo off
setlocal enabledelayedexpansion

:: installation paths
set PYTHON_INSTALLER=python-3.9.13-amd64.exe
set CUDA_INSTALLER=cuda_12.1.1_windows.exe
set MINICONDA_INSTALLER=Miniconda3-latest-Windows-x86_64.exe

:: check for python 3.9
python --version 2>NUL | findstr /R "3\.9\." >NUL
if %errorlevel% neq 0 (
    echo Downloading and Installing Python 3.9...
    curl -o %PYTHON_INSTALLER% https://www.python.org/ftp/python/3.9.13/python-3.9.13-amd64.exe
    start /wait %PYTHON_INSTALLER% /quiet InstallAllUsers=1 PrependPath=1
    del %PYTHON_INSTALLER%
) else (
    echo Python 3.9 is already installed.
)

:: ensurepip
python -m ensurepip
python -m pip install --upgrade pip

:: check cuda toolkit 12.1
where nvcc >nul 2>&1
if %errorlevel% neq 0 (
    echo Downloading and Installing CUDA Toolkit 12.1...
    curl -o %CUDA_INSTALLER% https://developer.download.nvidia.com/compute/cuda/12.1.1/network_installers/cuda_12.1.1_windows_network.exe
    start /wait %CUDA_INSTALLER% -s
    del %CUDA_INSTALLER%
) else (
    echo CUDA Toolkit 12.1 is already installed.
)

:: check conda
where conda >nul 2>&1
if %errorlevel% neq 0 (
    echo Downloading and Installing Miniconda...
    curl -o %MINICONDA_INSTALLER% https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe
    start /wait %MINICONDA_INSTALLER% /InstallationType=JustMe /RegisterPython=0 /AddToPath=1 /S
    del %MINICONDA_INSTALLER%
    set "CONDA_ROOT=%USERPROFILE%\Miniconda3"
) else (
    echo Conda is already installed.
    for /f "delims=" %%i in ('where conda') do set "CONDA_ROOT=%%~dpi"
)

call "%CONDA_ROOT%\condabin\conda.bat" init
call "%CONDA_ROOT%\condabin\conda.bat" config --set auto_activate_base false

:: Create Conda environment if not exists
call "%CONDA_ROOT%\condabin\conda.bat" env list | findstr /R "\<neo-pentest\>" >NUL
if %errorlevel% neq 0 (
    echo Creating Conda environment 'neo-pentest'...
    call "%CONDA_ROOT%\condabin\conda.bat" create -y -n neo-pentest python=3.9
) else (
    echo Conda environment 'neo-pentest' already exists.
)

call "%CONDA_ROOT%\condabin\conda.bat" activate neo-pentest
call conda install -y -c conda-forge vllm ray

echo Installation complete! You can activate the environment using:
echo conda activate neo-pentest

endlocal
