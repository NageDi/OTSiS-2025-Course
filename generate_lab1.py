import nbformat as nbf
import os

# Создаем новый ноутбук
nb = nbf.v4.new_notebook()

# Текст и код для ячеек
md_header = "# 📡 Лабораторная работа №1: Основы сигналов\n**Цель:** Научиться генерировать сигналы."

code_imports = "import numpy as np\nimport matplotlib.pyplot as plt\nplt.style.use('seaborn-v0_8')\nprint('Готово!')"

md_task = "## 🛠 ЗАДАНИЕ\nСгенерируйте сигнал $x(t) = e^{-3t} \cos(20 \pi t)$"

code_placeholder = "# ВАШ КОД ЗДЕСЬ"

# Добавляем ячейки
nb['cells'] = [
    nbf.v4.new_markdown_cell(md_header),
    nbf.v4.new_code_cell(code_imports),
    nbf.v4.new_markdown_cell(md_task),
    nbf.v4.new_code_cell(code_placeholder)
]

# Сохраняем файл
os.makedirs('notebooks/Lab1_Basics', exist_ok=True)
filename = 'notebooks/Lab1_Basics/Lab1_Signals.ipynb'

with open(filename, 'w', encoding='utf-8') as f:
    nbf.write(nb, f)

print(f"Файл создан: {filename}")
