%% Лабораторная работа №4: Цифровые фильтры в MATLAB
% Курс: ОТСиС 2025
% Студент: _________________
% Дата: _________________

%% 1. ПОДГОТОВКА
clear; clc; close all;

%% 2. ТЕОРИЯ: FIR vs IIR
% FIR (Finite Impulse Response):
%   + Всегда устойчив
%   + Линейная фаза (не искажает сигнал)
%   - Высокий порядок (много операций)
%
% IIR (Infinite Impulse Response):
%   + Низкий порядок (эффективен)
%   - Может быть неустойчив
%   - Нелинейная фаза (искажает форму)

%% 3. ПРОЕКТИРОВАНИЕ IIR ФИЛЬТРА (Butterworth)
fs = 1000;
t = 0:1/fs:2;

% Сигнал: полезный (2 Гц) + шум (50 Гц)
x = sin(2*pi*2*t) + 0.5*sin(2*pi*50*t);

% Проектируем Low-Pass фильтр Баттерворта
fc = 10;      % Частота среза 10 Гц
order = 4;    % 4-й порядок
[b, a] = butter(order, fc/(fs/2), 'low');

% Фильтрация (filtfilt - нулевая фазовая задержка)
y = filtfilt(b, a, x);

% Визуализация
figure('Name', 'Lab4_Butterworth', 'Color', 'w');

subplot(2,1,1);
plot(t(1:200), x(1:200), 'r', 'LineWidth', 0.5); hold on;
plot(t(1:200), y(1:200), 'b', 'LineWidth', 2);
title('Фильтрация Баттерворта (Low-Pass 10 Hz)');
legend('Шумный', 'Очищенный');
xlabel('Время, с');
grid on;

% АЧХ фильтра (Amplitude-Frequency Response)
[h, w] = freqz(b, a, 1024, fs);
subplot(2,1,2);
plot(w, 20*log10(abs(h)), 'b', 'LineWidth', 1.5);
title('АЧХ фильтра (Bode Plot)');
xlabel('Частота, Гц');
ylabel('Амплитуда, дБ');
xlim([0 100]);
ylim([-60 5]);
grid on;

%% 4. ПРОЕКТИРОВАНИЕ FIR ФИЛЬТРА (Window Method)
numtaps = 101;  % Количество коэффициентов
b_fir = fir1(numtaps-1, fc/(fs/2), 'low');

% Фильтрация (lfilter вносит задержку, filtfilt - исправляет)
y_fir = filtfilt(b_fir, 1, x);

% Сравнение
figure('Name', 'Lab4_FIR_vs_IIR', 'Color', 'w');
plot(t(1:100), x(1:100), 'gray', 'LineWidth', 0.5); hold on;
plot(t(1:100), y(1:100), 'b', 'LineWidth', 2, 'DisplayName', 'IIR');
plot(t(1:100), y_fir(1:100), 'g--', 'LineWidth', 1.5, 'DisplayName', 'FIR');
title('Сравнение FIR и IIR фильтров');
legend;
grid on;

%% 5. ЗАДАНИЕ: РЕЖЕКТОРНЫЙ ФИЛЬТР (NOTCH FILTER)
%
% Ситуация: В сигнал попал гул от электросети 50 Гц
% Задача: Вырезать ТОЛЬКО 50 Гц, оставив остальное
%
% Подход: Используем Band-Stop (Notch) фильтр

% 1. Генерируем сигнал
x_bad = sin(2*pi*10*t) + 0.6*sin(2*pi*50*t);

% 2. Проектируем Notch фильтр
% wo - нормализованная частота (на Найквист)
% bw - ширина полосы подавления
f0 = 50;      % Частота выреза
Q = 30;       % Качество (чем больше Q, тем уже вырез)
wo = f0/(fs/2);
bw = wo/Q;

% Создаем Notch фильтр
[b_notch, a_notch] = iirnotch(wo, bw);

% 3. Фильтрируем
y_clean = filtfilt(b_notch, a_notch, x_bad);

% 4. Спектральный анализ
L = length(x_bad);
f = fs*(0:(L/2))/L;

% Спектр ДО
X_bad = fft(x_bad);
P_bad = abs(X_bad/L);
P_bad = P_bad(1:floor(L/2)+1);

% Спектр ПОСЛЕ
X_clean = fft(y_clean);
P_clean = abs(X_clean/L);
P_clean = P_clean(1:floor(L/2)+1);

% Визуализация
figure('Name', 'Lab4_Notch_Filter', 'Color', 'w');

subplot(2,2,1);
plot(t(1:500), x_bad(1:500), 'r', 'LineWidth', 0.5);
title('Сигнал ДО (с помехой 50 Гц)');
grid on;

subplot(2,2,2);
plot(t(1:500), y_clean(1:500), 'g', 'LineWidth', 1.5);
title('Сигнал ПОСЛЕ (помеха удалена)');
grid on;

subplot(2,2,3);
plot(f, P_bad, 'r', 'LineWidth', 1);
title('Спектр ДО (пик 50 Гц видим)');
xlabel('Частота, Гц');
xlim([0 100]);
grid on;

subplot(2,2,4);
plot(f, P_clean, 'g', 'LineWidth', 1);
title('Спектр ПОСЛЕ (пик 50 Гц удален)');
xlabel('Частота, Гц');
xlim([0 100]);
grid on;

% Вывод
fprintf('\n===== РЕЗУЛЬТАТЫ NOTCH ФИЛЬТРА =====\n');
fprintf('Частота подавления: %.1f Гц\n', f0);
fprintf('Качество Q: %.1f\n', Q);
fprintf('Полоса подавления: %.1f - %.1f Гц\n', f0-2, f0+2);

%% КОНЕЦ ЛАБОРАТОРНОЙ РАБОТЫ №4
