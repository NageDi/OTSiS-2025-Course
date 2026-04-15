# Инструкция по сборке Simulink-модели — Лабораторная 1.8
## «Спектральный анализ сигналов»

**MATLAB/Simulink версии:** R2021b и выше  
**Toolbox:** Signal Processing Toolbox, DSP System Toolbox  
**Файл модели:** `lab1_8_spectral.slx` (создаётся по этой инструкции)  

---

## Часть А: Генератор сигнала + Scope

### Шаг 1: Создать новую модель
```
Simulink → New → Blank Model
Сохранить: File → Save As → lab1_8_spectral.slx
```

### Шаг 2: Настроить параметры симуляции
```
Menu: Simulation → Model Settings (Ctrl+E)
  Solver: Fixed-step, ode3 (Bogacki-Shampine)
  Fixed-step size: 1/2000   (= 1/fs, fs=2000 Гц)
  Stop time: 1.0             (1 секунда)
```

### Шаг 3: Добавить генераторы сигналов

Открыть **Library Browser** (Ctrl+Shift+L) → найти и перетащить:

| Блок | Библиотека | Параметры |
|------|-----------|-----------|
| `Sine Wave` | Sources | Frequency: `2*pi*100` (рад/с), Amplitude: `2`, Phase: `0` |
| `Sine Wave` (2-й) | Sources | Frequency: `2*pi*250` (рад/с), Amplitude: `1`, Phase: `0` |
| `Add` | Math Operations | — (сложить два синуса) |
| `Scope` | Sinks | — |
| `Spectrum Analyzer` | DSP System Toolbox → Sinks | — |

> ⚠️ **Важно:** Sine Wave в режиме `Discrete` → Source type: `Sample based`, Sample time: `1/2000`

### Шаг 4: Соединить блоки

```
[Sine Wave 100 Hz] ──┐
                     ├─→ [Add] ──→ [Scope]
[Sine Wave 250 Hz] ──┘        └──→ [Spectrum Analyzer]
```

### Шаг 5: Настроить Spectrum Analyzer

Двойной клик на `Spectrum Analyzer`:
```
Input domain:    Time
Sample rate:     2000  (Гц)
Number of spectral averages: 8
Window function: Hann
Reference load:  1 Ω
```

### Шаг 6: Запустить (Ctrl+T)

**Что наблюдать:**
- `Scope` — суммарный сигнал во временной области
- `Spectrum Analyzer` — два пика на 100 Гц и 250 Гц

---

## Часть Б: MATLAB Function (ДПФ) — продвинутый блок

### Шаг 7: Добавить блок MATLAB Function

```
Library Browser → User-Defined Functions → MATLAB Function
```

Двойной клик → внести код:
```matlab
function y = manual_dft(u)
    N = length(u);
    y = abs(fft(u, N)) * 2 / N;
end
```

Настроить `Mux` перед ним: собрать N=256 отсчётов через:
```
[Buffer] (DSP System Toolbox → Signal Management)
  Buffer size: 256
  Buffer overlap: 0
```

### Шаг 8: Итоговая схема Часть А+Б

```
[Sine 100] ──┐
             ├─→ [Add] ──→ [Buffer(256)] ──→ [MATLAB Function DFT] ──→ [Display/Scope]
[Sine 250] ──┘        └──→ [Spectrum Analyzer]
                       └──→ [Scope (время)]
```

---

## Часть В: Фильтрация в частотной области

### Шаг 9: Добавить цифровой фильтр

```
Library Browser → DSP System Toolbox → Filtering → Filter Designs → Lowpass Filter
  Pass frequency:  150 Гц
  Stop frequency:  200 Гц
  Sample rate:     2000 Гц
```

Включить **после** блока `Add`, параллельно:

```
[Add] ──→ [Lowpass Filter 150 Hz] ──→ [Scope 2 (отфильтрованный)]
      └──→ [Scope 1 (исходный)]
```

**Что наблюдать:**
- Scope 1: пики на 100 и 250 Гц
- Scope 2: только пик на 100 Гц (250 Гц подавлен)

---

## Часть Г: Сигнал с шумом

### Шаг 10: Добавить AWGN шум

```
Library Browser → Sources → Band-Limited White Noise
  Noise power:   0.1
  Sample time:   1/2000
```

Схема:
```
[Add (сигналы)] ──→ [Add (шум)] ──→ [Spectrum Analyzer]
                         ↑
                [Band-Limited White Noise]
```

Сравнить спектры **с шумом** и **без шума** в двух Spectrum Analyzer.

---

## Проверка результатов

После запуска модели выполнить в MATLAB Command Window:
```matlab
% Взять данные из Scope в workspace
% Scope → Logging → Log data to workspace → имя: 'scope_data'
lab1_8_validator    % Запуск валидатора
```

---

## Блок-схема итоговой модели

```
┌─────────────────────────────────────────────────────────────────┐
│                    lab1_8_spectral.slx                          │
│                                                                 │
│  [Sine 100 Hz] ──┐                                              │
│                  ├─→ [Add] ──┬──→ [Scope: время]               │
│  [Sine 250 Hz] ──┘           ├──→ [Spectrum Analyzer]           │
│                              ├──→ [Add+Noise] → [SA с шумом]   │
│                              └──→ [LPF 150 Hz] → [Scope: филь] │
│                                                                 │
│  [Buffer 256] ──→ [MATLAB Fn: DFT] ──→ [Display: амплитуды]    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Частые ошибки

| Ошибка | Причина | Решение |
|--------|---------|---------|
| «Sample time mismatch» | Sine Wave в непрерывном режиме | Переключить в Discrete, sample time = 1/2000 |
| Spectrum Analyzer пустой | Мало отсчётов | Увеличить Stop time до 2 с |
| MATLAB Function ошибка | Размер буфера не совпадает | Buffer size = 256, MATLAB Fn вход тоже 256 |
| Фильтр не работает | Неверная нормировка частот | в DSP Toolbox частоты в Гц (не рад/с) |

---

## Отчёт по лабораторной

Студент должен сдать:
1. Скриншот схемы Simulink-модели
2. Скриншот Spectrum Analyzer (исходный + отфильтрованный)
3. Скриншот Scope (сигнал с шумом)
4. Заполненный `lab1_8_template.m` с результатами валидатора
5. Вывод: на каких частотах находятся гармоники и как фильтр изменил спектр
