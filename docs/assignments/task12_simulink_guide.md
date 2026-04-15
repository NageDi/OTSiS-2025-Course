---
layout: default
title: Инструкция по сборке Simulink-модели — Задание 12
parent: Домашние задания
---

# Инструкция по сборке Simulink-модели — Задание 12
## «Канал связи BPSK с AWGN. Оценка BER.»

**MATLAB/Simulink версии:** R2021b и выше  
**Toolbox:** Communications Toolbox (обязательно!)  
**Файл модели:** `task12_channel.slx`  

---

## Минимальная схема (быстрый старт)

```
[Random Integer] → [BPSK Modulator] → [AWGN Channel] → [BPSK Demodulator] → [BER Display]
```

Все блоки из **Communications Toolbox**.

---

## Пошаговая сборка

### Шаг 1: Создать новую модель

```
Simulink → New → Blank Model
File → Save As → task12_channel.slx

Simulation → Model Settings (Ctrl+E):
  Solver:         Fixed-step, Discrete (no continuous states)
  Fixed-step:     1/10000
  Stop time:      0.1    (= N_bits/Rb = 1000/1000 * 2, с запасом)
```

### Шаг 2: Random Integer Generator (источник бит)

```
Library: Communications → Source Coding → Random Integer Generator
  M-ary number:          2      (двоичный: 0 и 1)
  Initial seed:          37
  Sample time:           1/1000  (= 1/Rb, 1000 бит/с)
  Samples per frame:     1
  Output data type:      double
```

### Шаг 3: BPSK Modulator Baseband

```
Library: Communications → Modulation → Digital Baseband Modulation → BPSK Modulator Baseband
  Phase offset (rad):    0
  Symbol order:          binary
```

> 💡 **Вариант**: использовать `BPSK Modulator Passband` для сигнала на реальной несущей (fc=2000 Гц).  
> Для Passband-версии добавить параметр `Carrier frequency: 2000`.

### Шаг 4: AWGN Channel

```
Library: Communications → Channels → AWGN Channel
  Initial seed:          67
  Mode:                  Signal to noise ratio (Eb/No)
  Eb/No (dB):            6       ← ИЗМЕНЯТЬ при исследовании BER
  Number of bits per symbol: 1   (BPSK)
  Signal power (W):      1
  Symbol period (s):     1/1000  (=1/Rb)
```

### Шаг 5: BPSK Demodulator Baseband

```
Library: Communications → Modulation → Digital Baseband Modulation → BPSK Demodulator Baseband
  Phase offset (rad):    0
  Decision type:         Hard decision
  Output data type:      double
```

### Шаг 6: Error Rate Calculation + BER Display

```
Library: Communications → Comm Sinks → Error Rate Calculation
  Receive delay:         0
  Computation delay:     0
  Output data:           Port    (вывод в workspace)

Library: Sinks → Display
  (подключить к Error Rate Calculation, выход 1 = BER)
```

---

## Итоговая схема

```
┌─────────────────────────────────────────────────────────────────┐
│                    task12_channel.slx                           │
│                                                                 │
│  [Random Integer] ──→ [BPSK Mod] ──→ [AWGN Channel (6 дБ)]    │
│          │                                      │               │
│          │                           [BPSK Demod]              │
│          │                                      │               │
│          └───────────────────→ [Error Rate Calc] ──→ [Display] │
│                                      │                          │
│                               [To Workspace: BER_data]         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Подключение к MATLAB workspace

### Добавить блок «To Workspace»

```
Library: Sinks → To Workspace
  Variable name:    BER_data
  Limit data points:  inf
  Decimation:         1
  Save format:        Array
```

Подключить к выходу `Error Rate Calculation`.

После остановки симуляции:
```matlab
BER_simulink = BER_data(1);    % Первый элемент = BER
fprintf('BER Simulink (6 dB) = %.4e\n', BER_simulink);
task12_grader                  % Запустить проверку
```

---

## Исследование кривой BER

Для построения кривой BER(Eb/N0) — менять параметр Eb/No блока AWGN вручную или через скрипт:

```matlab
% Из MATLAB: автоматический перебор Eb/N0
EbN0_list = [0, 2, 4, 6, 8, 10];
BER_sim = zeros(1, length(EbN0_list));

for i = 1:length(EbN0_list)
    % Изменить параметр блока AWGN
    set_param('task12_channel/AWGN Channel', 'EbNo', num2str(EbN0_list(i)));
    % Запустить симуляцию на 10000 бит
    set_param('task12_channel', 'StopTime', '10');  % 10 с = 10000 бит
    sim('task12_channel');
    BER_sim(i) = BER_data(1);
    fprintf('Eb/N0 = %d dB → BER = %.4e\n', EbN0_list(i), BER_sim(i));
end

% Сравнить с теоретическим
BER_theory = erfc(sqrt(10.^(EbN0_list/10)))/2;
figure;
semilogy(EbN0_list, BER_theory, 'b-', EbN0_list, BER_sim, 'ro--');
legend('Теория', 'Simulink'); grid on;
xlabel('Eb/N0, дБ'); ylabel('BER');
title('Кривая BER — BPSK (теория vs Simulink)');
```

---

## Расширенная схема с Scope и Constellation

### Добавить Constellation Diagram

```
Library: Communications → Comm Sinks → Constellation Diagram
  Подключить к выходу BPSK Modulator:
    — до AWGN (идеальное созвездие: 2 точки ±1)
  Подключить к выходу AWGN:
    — после шума (облака точек вокруг ±1)
```

### Добавить Eye Diagram

```
Library: Communications → Comm Sinks → Eye Diagram
  Подключить к выходу AWGN Channel
  Samples per symbol: 10   (= spb = fs/Rb = 10000/1000)
  Symbols per trace:  2
```

---

## Параметры блоков — сводная таблица

| Блок | Параметр | Значение |
|------|---------|---------|
| Random Integer | M-ary | 2 |
| Random Integer | Sample time | 1/1000 |
| BPSK Modulator | Phase offset | 0 |
| AWGN Channel | Eb/No | **6** (изменять!) |
| AWGN Channel | Symbol period | 1/1000 |
| Error Rate Calc | Receive delay | 0 |
| Stop time | — | 0.1–10 с |

---

## Частые ошибки

| Ошибка | Причина | Решение |
|--------|---------|---------|
| «Communications Toolbox not found» | Нет лицензии | Использовать только MATLAB-скрипт (task12_template.m) |
| BER всегда 0 или 0.5 | Неверный Receive delay | Проверить задержку; установить 0 |
| BER не сходится | Мало бит | Stop time = 10 с (10000 бит при Rb=1000) |
| Constellation Diagram пустой | Sample time mismatch | Все блоки — один Sample time = 1/1000 |

---

## Соответствие переменных

| Переменная MATLAB | Блок Simulink |
|------------------|--------------|
| `bits` | Выход Random Integer Generator |
| `x_bpsk` | Выход BPSK Modulator |
| `BER_measured` | Выход Error Rate Calculation (порт 1) |
| `BER_simulink` | `BER_data(1)` после `sim()` |

---

## Отчёт по заданию 12

Студент сдаёт:
1. Скриншот собранной схемы `task12_channel.slx`
2. Скриншот Constellation Diagram (до и после шума)
3. Значение `BER_simulink` при Eb/N0 = 6 дБ
4. Сравнение `BER_simulink` с `BER_theory` (таблица и график)
5. Заполненный `task12_template.m` + результат `task12_grader.m`
