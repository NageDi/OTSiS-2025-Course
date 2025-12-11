%% Лабораторная работа №2: DFT/FFT и спектральный анализ в MATLAB
% Курс: ОТСиС 2025
% Студент: _________________

%% 1. ПОДГОТОВКА
clear; clc; close all;

%% 2. ТЕОРИЯ: DFT и FFT
%
% DFT переводит сигнал из временной области в частотную:
% X[k] = sum(x[n] * exp(-j*2*pi*k*n/N)), n=0..N-1
%
% FFT - быстрый алгоритм вычисления DFT
% Амплитудный спектр: |X[k]| = sqrt(Real^2 + Imag^2)
% Фазовый спектр: angle(X[k]) = atan2(Imag, Real)

%% 3. БАЗОВЫЙ ПРИМЕР
fs = 1000;  % Частота дискретизации
t = 0:1/fs:1-1/fs;  % Вектор времени (1 сек)

% Сигнал: микс из 3 частот
f1 = 10; f2 = 25; f3 = 50;  % Герцы
s = sin(2*pi*f1*t) + 0.5*sin(2*pi*f2*t) + 0.3*sin(2*pi*f3*t);

% FFT
N = length(s);
S = fft(s);  % Комплексный спектр
freqs = (0:N-1) * fs/N;  % Оси частот

% Нормировка и берем только положительные частоты
S_normalized = abs(S) / N;
S_positive = S_normalized(1:N/2);
freqs_positive = freqs(1:N/2);

% Визуализация
figure('Name', 'Lab2_Basic_FFT', 'Color', 'w');

subplot(2,1,1);
plot(t(1:100), s(1:100), 'b', 'LineWidth', 1.5);
title('Исходный сигнал (первые 100 отсчетов)');
xlabel('Время, с');
ylabel('Амплитуда');
grid on;

subplot(2,1,2);
plot(freqs_positive, S_positive, 'r', 'LineWidth', 1.5);
title('Амплитудный спектр (FFT)');
xlabel('Частота, Гц');
ylabel('Амплитуда (нормированная)');
xlim([0 100]);
grid on;

%% 4. УТЕЧКА СПЕКТРА И ОКОННЫЕ ФУНКЦИИ

% Сигнал, который не кратен периоду
fs2 = 1000;
duration = 0.95;  % НЕ целая секунда
t2 = 0:1/fs2:duration-1/fs2;
f = 10;  % Частота 10 Гц
s_noperiodic = sin(2*pi*f*t2);

% FFT без окна и с окном
N2 = length(s_noperiodic);
freqs2 = (0:N2-1) * fs2/N2;

% Без окна
S_no_window = abs(fft(s_noperiodic)) / N2;

% С окном Hamming
window_hamming = hamming(N2)';
s_windowed = s_noperiodic .* window_hamming;
S_hamming = abs(fft(s_windowed)) / N2;

% Берем положительные частоты
S_no_window = S_no_window(1:N2/2);
S_hamming = S_hamming(1:N2/2);
freqs2_positive = freqs2(1:N2/2);

% Визуализация
figure('Name', 'Lab2_Windowing', 'Color', 'w');

% Исходный сигнал
subplot(2,2,1);
plot(t2, s_noperiodic, 'b');
title('Исходный сигнал (не кратен периоду)');
xlabel('Время, с');
grid on;

% Оконный сигнал
subplot(2,2,2);
plot(t2, s_windowed, 'g');
title('После применения окна Hamming');
xlabel('Время, с');
grid on;

% Спектр без окна (утечка!)
subplot(2,2,3);
semilogy(freqs2_positive, S_no_window);
title('Спектр БЕЗ окна (видна утечка)');
xlabel('Частота, Гц');
xlim([0 50]);
grid on;

% Спектр с окном (чище)
subplot(2,2,4);
semilogy(freqs2_positive, S_hamming);
title('Спектр С окном Hamming');
xlabel('Частота, Гц');
xlim([0 50]);
grid on;

%% 5. ЗАДАНИЕ: СПЕКТРАЛЬНЫЙ АНАЛИЗ СИНТЕТИЧЕСКОГО ГОЛОСА

% Параметры "голоса"
fs3 = 8000;
t3 = 0:1/fs3:2-1/fs3;

% Синтетический "голос": основная частота 200 Гц + гармоники
f0 = 200;
harmonics = f0 * [1, 2, 3, 4, 5];
amplitudes = [1.0, 0.5, 0.3, 0.2, 0.1];

% Генерируем сигнал
s_voice = zeros(size(t3));
for i = 1:length(harmonics)
    s_voice = s_voice + amplitudes(i) * sin(2*pi*harmonics(i)*t3);
end

% Добавим шум
s_voice = s_voice + 0.05 * randn(size(t3));

% Применяем окно Hann
window_hann = hann(length(s_voice))';
s_windowed_voice = s_voice .* window_hann;

% FFT
N3 = length(s_windowed_voice);
S_voice = abs(fft(s_windowed_voice)) / N3;
freqs3 = (0:N3-1) * fs3/N3;

% Берем положительные частоты
S_voice_positive = S_voice(1:N3/2);
freqs3_positive = freqs3(1:N3/2);

% Находим топ-5 пиков
[sorted_amps, indices] = sort(S_voice_positive, 'descend');
top_5_indices = indices(1:5);
top_5_freqs = freqs3_positive(top_5_indices);
top_5_amps = sorted_amps(1:5);

% Визуализация
figure('Name', 'Lab2_Voice_Analysis', 'Color', 'w');

% Волна
subplot(2,1,1);
plot(t3(1:1000), s_voice(1:1000), 'b', 'LineWidth', 0.5);
hold on;
plot(t3(1:1000), window_hann(1:1000), 'r--', 'LineWidth', 1);
title('Синтетический "голос" с окном Hann');
xlabel('Время, с');
ylabel('Амплитуда');
legend('Сигнал', 'Окно');
grid on;

% Спектр (логарифмическая шкала)
subplot(2,1,2);
semilogy(freqs3_positive, S_voice_positive, 'g', 'LineWidth', 1);
hold on;
scatter(top_5_freqs, top_5_amps, 100, 'r', 'filled', 'o');
title('Спектр "голоса" (логарифмическая шкала)');
xlabel('Частота, Гц');
ylabel('Амплитуда');
xlim([0 1000]);
grid on;
legend('Спектр', 'Топ-5 пиков');

% Вывод результатов
fprintf('\n=== ТОП-5 ПИКОВ СПЕКТРА ===\n');
for i = 1:5
    fprintf('%d. Частота: %.1f Гц, Амплитуда: %.4f\n', i, top_5_freqs(i), top_5_amps(i));
end

%% КОНЕЦ ЛАБОРАТОРНОЙ РАБОТЫ №2
