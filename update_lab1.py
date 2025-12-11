import nbformat as nbf
import os

nb = nbf.v4.new_notebook()

# Ячейка 1: Заголовок
md1 = "# 📡 Лабораторная работа №1: Основы сигналов\n**Цель:** Научиться генерировать и анализировать сигналы в Python."

# Ячейка 2: Импорты
code_imports = """import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

plt.style.use('seaborn-v0_8-whitegrid')
plt.rcParams['figure.figsize'] = (10, 6)
print('✅ Библиотеки готовы!')"""

# Ячейка 3: Генерация времени
md2 = "## 1. Дискретное время\nМы создаем массив времени с частотой дискретизации 1000 Гц."

code_time = """fs = 1000
t = np.arange(0, 1.0, 1/fs)

print(f"Всего отсчетов: {len(t)}")
print(f"Первые 5 значений: {t[:5]}")"""

# Ячейка 4: Генерация сигналов
md3 = "## 2. Генерация сигналов"

code_signals = """# Синус 5 Гц
s_sine = np.sin(2 * np.pi * 5 * t)

# Меандр 2 Гц
s_square = signal.square(2 * np.pi * 2 * t)

# Шум
noise = 0.2 * np.random.randn(len(t))

# Смесь
s_noisy = s_sine + noise"""

# Ячейка 5: Визуализация примеров
md4 = "## 3. Визуализация примеров"

code_plot = """fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, sharex=True, figsize=(10, 8))

ax1.plot(t, s_sine, 'b', linewidth=2)
ax1.set_title('Синус 5 Гц')
ax1.set_ylabel('Амплитуда')
ax1.grid(True)

ax2.plot(t, s_noisy, 'r', alpha=0.7)
ax2.plot(t, s_sine, 'b--', label='Идеал')
ax2.set_title('Синус + Шум')
ax2.legend()
ax2.grid(True)

ax3.plot(t, s_square, 'g', linewidth=2)
ax3.set_title('Меандр 2 Гц')
ax3.set_xlabel('Время (с)')
ax3.grid(True)

ax4.plot(t, noise, 'purple', alpha=0.7)
ax4.set_title('Шум')
ax4.set_xlabel('Время (с)')
ax4.grid(True)

plt.tight_layout()
plt.show()"""

# Ячейка 6: Задание
md5 = """## 🛠 ЗАДАНИЕ: Затухающая синусоида

Сгенерируйте сигнал: $x(t) = e^{-3t} \cos(2\pi \cdot 10 \cdot t)$

Требования:
1. Создайте вектор t от 0 до 2 секунд
2. Рассчитайте x(t)
3. Постройте график (цвет: оранжевый)
4. Подпишите оси и добавьте сетку"""

# Ячейка 7: Решение
code_task = """# Новый вектор времени (0 до 2 с)
t_task = np.arange(0, 2.0, 1/fs)

# Затухающая синусоида
x_damped = np.exp(-3*t_task) * np.cos(2*np.pi*10*t_task)

# График
plt.figure(figsize=(10, 5))
plt.plot(t_task, x_damped, color='orange', linewidth=2)
plt.title('Затухающая синусоида: $x(t) = e^{-3t} \cos(2\pi \cdot 10 \cdot t)$')
plt.xlabel('Время, с')
plt.ylabel('Амплитуда')
plt.grid(True)
plt.xlim([0, 2])
plt.ylim([-1.2, 1.2])
plt.legend(['$x(t) = e^{-3t} \cos(2\pi \cdot 10 \cdot t)$'])
plt.show()

# Анализ
print(f"Max: {x_damped.max():.4f}")
print(f"Min: {x_damped.min():.4f}")
print(f"Энергия: {(x_damped**2).sum() * (1/fs):.4f}")"""

# Собираем ноутбук
nb['cells'] = [
    nbf.v4.new_markdown_cell(md1),
    nbf.v4.new_code_cell(code_imports),
    nbf.v4.new_markdown_cell(md2),
    nbf.v4.new_code_cell(code_time),
    nbf.v4.new_markdown_cell(md3),
    nbf.v4.new_code_cell(code_signals),
    nbf.v4.new_markdown_cell(md4),
    nbf.v4.new_code_cell(code_plot),
    nbf.v4.new_markdown_cell(md5),
    nbf.v4.new_code_cell(code_task)
]

# Сохраняем
os.makedirs('notebooks/Lab1_Basics', exist_ok=True)
with open('notebooks/Lab1_Basics/Lab1_Signals.ipynb', 'w', encoding='utf-8') as f:
    nbf.write(nb, f)

print("✅ Lab1_Signals.ipynb обновлен!")
