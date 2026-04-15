# Инструкция по сборке Simulink-модели — Лабораторная 2.7
## «Импульсно-модулированные сигналы (PAM, PWM, PPM)»

**MATLAB/Simulink версии:** R2021b и выше  
**Toolbox:** Communications Toolbox, Signal Processing Toolbox  
**Файл модели:** `lab2_7_pulse_mod.slx`  

---

## Общая архитектура модели

```
┌──────────────────────────────────────────────────────────────────┐
│                      lab2_7_pulse_mod.slx                        │
│                                                                  │
│  ИСТОЧНИК ──→ МОДУЛЯТОР ──→ КАНАЛ (AWGN) ──→ ДЕМОДУЛЯТОР        │
│                                    ↓                             │
│                              [Scope + SA]   ← анализ             │
└──────────────────────────────────────────────────────────────────┘
```

---

## Часть А: PAM (Амплитудно-импульсная модуляция)

### Шаг 1: Создать модель

```
Simulink → New → Blank Model → сохранить как lab2_7_pulse_mod.slx
Simulation → Model Settings:
  Sample time: 1/10000  (fs=10 кГц)
  Stop time: 0.05       (50 мс — 5 периодов несущей 100 Гц)
```

### Шаг 2: Источник (модулирующий сигнал)

| Блок | Параметры |
|------|-----------|
| `Sine Wave` | Frequency: 2*pi*100, Amplitude: 1, Sample time: 1/10000 |

### Шаг 3: PAM — импульсный выборщик

В Simulink нет готового блока PAM, строим из примитивов:

```
Library → Sources → Pulse Generator
  Pulse type:   Sample based
  Period:       100         (= fs/fs_PAM = 10000/100 отсчётов)
  Pulse width:  10          (10% — длительность импульса)
  Sample time:  1/10000
```

Схема PAM:
```
[Sine Wave] ──┐
              ├─→ [Product] ──→ [Scope PAM]
[Pulse Gen]  ──┘
```

**Результат:** сигнал PAM — синус, «прерванный» импульсами.

---

## Часть Б: PWM (Широтно-импульсная модуляция)

### Шаг 4: Компаратор для ШИМ

```
[Sine Wave 100 Hz] ──┐
                     ├─→ [Relational Operator (>=)] ──→ [Scope PWM]
[Sawtooth Gen]    ──┘

Sawtooth Generator:
  Library → Sources → Sine Wave
  (или создать через MATLAB Function)
```

Альтернатива — блок **Pulse Width Modulator** (если есть Communications Toolbox):
```
Library → Communications → Analog Passband Modulation → PWM
  Carrier frequency: 1000 Гц
  Sample time: 1/10000
```

Ручная реализация через MATLAB Function:
```matlab
function y = pwm_gen(x_mod, f_carrier, fs)
    % x_mod — модулирующий сигнал [-1..1]
    % f_carrier — частота пилы
    t = (0:length(x_mod)-1)/fs;
    sawtooth = 2*mod(f_carrier*t, 1) - 1;   % пила [-1..1]
    y = double(x_mod >= sawtooth);            % 1 если x_mod > пила
end
```

---

## Часть В: PPM (Позиционно-импульсная модуляция)

### Шаг 5: PPM через MATLAB Function блок

```matlab
function y = ppm_gen(x_mod, f_pulse, fs)
    % Смещение положения импульса пропорционально x_mod
    N = length(x_mod);
    y = zeros(1, N);
    period = round(fs / f_pulse);      % отсчётов на период
    for i = 1:period:N
        % Смещение: от 0 до period/2 в зависимости от x_mod
        shift = round((x_mod(i)+1)/2 * period/2);
        pos = i + shift;
        if pos <= N
            y(pos) = 1;
        end
    end
end
```

---

## Часть Г: Канал с шумом → Демодуляция

### Шаг 6: AWGN канал

```
Library → Communications → Channels → AWGN Channel
  Eb/No (dB):       10
  Signal power:     1 (Вт, measured)
  Symbol period:    1/10000
```

### Шаг 7: ФНЧ (восстановление исходного сигнала)

```
Library → DSP System Toolbox → Filtering → Lowpass Filter
  Pass frequency:  150 Гц
  Stop frequency:  300 Гц
  Sample rate:     10000 Гц
```

### Шаг 8: Итоговая схема (PAM ветка)

```
[Sine 100 Hz] ──┬──────────────────────────────────────┐ (эталон)
                │                                       │
                └──→ [Product] ──→ [AWGN] ──→ [LPF] ──→ [Add(inv)] ──→ [Scope: ошибка]
                          ↑
                    [Pulse Gen]
```

---

## Шаг 9: Измерение качества — блок SNR

```
Library → DSP System Toolbox → Statistics → Mean
(Для ручного SNR) или:

MATLAB Function блок:
function snr_val = compute_snr(original, recovered)
    P_sig = mean(original.^2);
    P_err = mean((original - recovered).^2);
    snr_val = 10*log10(P_sig / P_err);
end
```

---

## Параметры блоков — сводная таблица

| Блок | Параметр | Значение |
|------|---------|---------|
| Sine Wave (модулирующий) | Frequency | 2π·100 рад/с |
| Sine Wave (модулирующий) | Sample time | 1/10000 |
| Pulse Generator (PAM) | Period | 100 отсчётов |
| Pulse Generator (PAM) | Pulse width | 10% |
| AWGN Channel | Es/No mode | SNR |
| AWGN Channel | SNR | 20 дБ (чистый), 10 дБ (зашумлённый) |
| Lowpass Filter | Pass freq | 150 Гц |
| Stop time | — | 0.05 с |
| Sample time | — | 1/10000 с |

---

## Блок-схема итоговой модели

```
┌──────────────────────────────────────────────────────────┐
│                   lab2_7_pulse_mod.slx                   │
│                                                          │
│ [Sine 100Hz] ──→ [PAM] ──→ [AWGN 10dB] ──→ [LPF] ──→ [Scope PAM demod] │
│             └──→ [PWM] ──→ [AWGN 10dB] ──→ [LPF] ──→ [Scope PWM demod] │
│             └──→ [PPM fn] ─────────────────────────────→ [Scope PPM]    │
│                                                          │
│ [SNR Calculator] ← (original vs recovered)              │
└──────────────────────────────────────────────────────────┘
```

---

## Связь с MATLAB (lab2_7_template.m)

После запуска модели — передать данные в MATLAB:

```matlab
% В Scope → настройки → "Log data to workspace":
%   Variable name: pam_out, pwm_out, ppm_out

% Затем выполнить:
sim('lab2_7_pulse_mod');         % Запуск из MATLAB
% Переменные pam_out, pwm_out появятся в workspace
lab2_7_validator                 % Автопроверка
```

---

## Частые ошибки

| Ошибка | Причина | Решение |
|--------|---------|---------|
| «Algebraic loop» | Обратная связь без задержки | Добавить блок `Unit Delay` |
| Неверная частота Sine Wave | Путаница рад/с vs Гц | В Simulink по умолчанию рад/с: f_рад = 2π·f_Гц |
| AWGN ошибка размерности | Разные sample time блоков | Проверить, что все блоки имеют одинаковый Sample time |
| LPF не фильтрует | Pass freq в нормированных единицах | В DSP LPF : частоты в Гц при указанном Sample rate |

---

## Отчёт

Студент сдаёт:
1. Скриншоты моделей PAM, PWM, PPM
2. Осциллограммы: модулирующий сигнал / PAM / восстановленный
3. SNR при разных уровнях шума (таблица)
4. Вывод: сравнение трёх видов импульсной модуляции
