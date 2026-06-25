#!/bin/bash

cd "$(dirname "$0")"

# 1. Instalar pyenv si no existe
if [ ! -d "$HOME/.pyenv" ]; then
    curl https://pyenv.run | bash
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# 2. Instalar Python 3.11 si no está disponible
if ! pyenv versions | grep -q "3.11"; then
    pyenv install 3.11.9
fi

PYTHON_CMD="$HOME/.pyenv/versions/3.11.9/bin/python3"

# 3. Limpiar venv anterior si existe
if [ -d "rl_env" ]; then
    rm -rf rl_env
fi

# 4. Crear entorno virtual
$PYTHON_CMD -m venv rl_env

if [ ! -d "rl_env" ]; then
    exit 1
fi

VENV_PYTHON="./rl_env/bin/python"
VENV_PIP="./rl_env/bin/pip"

# 5. Actualizar pip e instalar Jupyter
$VENV_PYTHON -m pip install --upgrade pip --quiet
$VENV_PIP install ipykernel nbconvert --quiet
if [ $? -ne 0 ]; then
    exit 1
fi

# 6. Instalar dependencias
if [ -f requirements.txt ]; then
    $VENV_PIP install -r requirements.txt
else
    $VENV_PIP install tensorflow pandas numpy matplotlib seaborn mplfinance ta-lib tqdm
fi

# 7. Verificar módulos críticos
MISSING=0
for MODULE in pandas numpy matplotlib tensorflow; do
    $VENV_PYTHON -c "import $MODULE" 2>/dev/null
    if [ $? -ne 0 ]; then
        MISSING=1
    else
    fi
done

if [ $MISSING -eq 1 ]; then
    exit 1
fi

# 8. Registrar kernel
$VENV_PYTHON -m ipykernel install --user \
    --name=rl_env \
    --display-name "Python (stock market)" --quiet

echo "ENTORNO CONFIGURADO CORRECTAMENTE"
