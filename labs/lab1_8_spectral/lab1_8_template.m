%% ============================================================
%% lab1_8_template.m — Шаблон для студента
%% Лабораторная работа 1.8: Спектральный анализ сигналов
%% ============================================================
%% Инструкция:
%%   1. Заполните все места, помеченные ??? или TODO
%%   2. Запустите весь скрипт без ошибок
%%   3. Запустите lab1_8_validator.m для автопроверки
%%
%% ФИО: ___________________________________
%% Группа: ________________________________
%% Дата: __________________________________

clear; close all; clc;
rng(42);    % Фиксируем генератор — не изменять!

%% ════════════════════════════════════════════════════════════
%% РАЗДЕЛ А: Разложение в ряд Фурье
%% ════════════════════════════════════════════════════════════

%% А1: Синтез прямоугольного сигнала через ряд Фурье
% ─────────────────────────────────────────────────
fprintf('--- РАЗДЕЛ А1: Ряд Фурье ---\n');

T_f   = 1;              % Период, с
A_f   = 1;              % Амплитуда
fs_f  = 2000;           % Частота дискретизации
t_f   = 0:1/fs_f:2*T_f-1/fs_f;  % Два периода
N_vals = [1, 3, 7, 15, 31];      % Число гармоник

% Идеальный прямоугольный сигнал (для расчёта ошибки)
x_ideal = A_f * square(2*pi/T_f * t_f);

x_fourier_N = zeros(5, length(t_f));  % Матрица 5xN
rmse_fourier = zeros(5, 1);           % Вектор погрешностей

figure('Name', 'А1: Синтез ряда Фурье — явление Гиббса');

for i = 1:5
    N_harm = N_vals(i);
    
    % TODO: Синтезировать x_fourier_N(i,:) по формуле:
    % x_N(t) = (4*A/π) * Σ_{k=1,3,5,...,N} (1/k)*sin(2π*k*t/T)
    x_sum = zeros(1, length(t_f));
    for k = 1 : 2 : N_harm
        x_sum = x_sum + ???;  % (1/k)*sin(2*pi*k*t_f/T_f)
    end
    x_fourier_N(i,:) = (4*A_f/pi) * x_sum;
    
    % TODO: Вычислить среднеквадратичную погрешность
    rmse_fourier(i) = sqrt(mean((x_fourier_N(i,:) - x_ideal).^2));
    
    % График
    subplot(5,1,i);
    plot(t_f, x_ideal, 'k--', 'LineWidth',0.5); hold on;
    plot(t_f, x_fourier_N(i,:), 'b', 'LineWidth',1.2);
    ylabel(sprintf('N=%d', N_harm));
    title(sprintf('N=%d гармоник | RMSE=%.4f', N_harm, rmse_fourier(i)));
    grid on; ylim([-1.5 1.5]);
end
xlabel('Время, с');
sgtitle('Приближение прямоугольного сигнала рядом Фурье (явление Гиббса)');

fprintf('RMSE для N = [1,3,7,15,31]: ');
fprintf('%.4f ', rmse_fourier);
fprintf('\n');

%% А2: Спектр прямоугольного и треугольного сигналов
% ─────────────────────────────────────────────────
fprintf('\n--- РАЗДЕЛ А2: Спектры ---\n');

f0_a2 = 5;              % Частота, Гц
fs_a2 = 2000;
T_a2  = 1;              % Длительность (несколько периодов)
t_a2  = 0:1/fs_a2:T_a2-1/fs_a2;
N_a2  = length(t_a2);

% TODO: Сгенерировать прямоугольный сигнал: square(2*pi*f0_a2*t_a2)
x_rect_a2 = ???;

% TODO: Сгенерировать треугольный сигнал: sawtooth(2*pi*f0_a2*t_a2, 0.5)
x_tri_a2  = ???;

% TODO: Вычислить ДПФ обоих сигналов
X_dft = fft(x_rect_a2, N_a2);
X_tri = fft(x_tri_a2,  N_a2);

f_a2 = (-N_a2/2:N_a2/2-1) * fs_a2/N_a2;  % Двусторонняя ось частот

figure('Name', 'А2: Спектры прямоугольного и треугольного сигналов');
subplot(2,2,1);
plot(t_a2, x_rect_a2); xlabel('Время, с'); ylabel('x(t)');
title('Прямоугольный сигнал'); grid on;

subplot(2,2,2);
% TODO: Построить двусторонний амплитудный спектр прямоугольного (fftshift)
stem(f_a2, abs(fftshift(X_dft))*2/N_a2, 'filled', 'MarkerSize',3);
xlabel('Частота, Гц'); ylabel('|X(f)|');
title('Спектр прям. сигнала (1/n убывание)');
xlim([-15*f0_a2  15*f0_a2]); grid on;

subplot(2,2,3);
plot(t_a2, x_tri_a2); xlabel('Время, с'); ylabel('x(t)');
title('Треугольный сигнал'); grid on;

subplot(2,2,4);
% TODO: Построить двусторонний спектр треугольного
stem(f_a2, abs(fftshift(X_tri))*2/N_a2, 'filled', 'MarkerSize',3);
xlabel('Частота, Гц'); ylabel('|X(f)|');
title('Спектр треуг. сигнала (1/n² убывание)');
xlim([-15*f0_a2  15*f0_a2]); grid on;

%% ════════════════════════════════════════════════════════════
%% РАЗДЕЛ Б: Оконный анализ и утечка спектра
%% ════════════════════════════════════════════════════════════

fprintf('\n--- РАЗДЕЛ Б1: Оконные функции ---\n');

N_w   = 256;            % Длина анализа
fs_w  = 1000;           % Частота дискретизации
n_w   = (0:N_w-1)';
% Сигнал с частотой, НЕ кратной шагу ДПФ → утечка спектра
f_leak = 157.3;
x_w = sin(2*pi*f_leak/fs_w * n_w);

% Четыре оконные функции
windows = {rectwin(N_w), hann(N_w), hamming(N_w), blackman(N_w)};
win_names = {'Прямоугольное', 'Ханна', 'Хэмминга', 'Блэкмана'};

spectra_windows = zeros(4, N_w/2);  % ← для валидатора

figure('Name', 'Б1: Сравнение оконных функций');
for i = 1:4
    % TODO: Применить окно к сигналу и вычислить спектр
    x_windowed = x_w .* windows{i};
    X_w = fft(???);     % fft(x_windowed, N_w)
    spectra_windows(i,:) = abs(X_w(1:N_w/2)) * 2/N_w;
    
    subplot(2,2,i);
    f_w_axis = (0:N_w/2-1)*fs_w/N_w;
    plot(f_w_axis, 20*log10(spectra_windows(i,:) + eps));
    xlabel('Частота, Гц'); ylabel('дБ');
    title(sprintf('Окно %s', win_names{i}));
    xlim([0 fs_w/2]); ylim([-80 10]); grid on;
    xline(f_leak,'r--','f_{утечки}');
end
sgtitle('Утечка спектра при разных оконных функциях');

%% Б2: Оценка PSD через Welch
fprintf('\n--- РАЗДЕЛ Б2: Welch PSD ---\n');

fs_b2 = 1000; T_b2 = 5;
t_b2  = (0:1/fs_b2:T_b2-1/fs_b2)';
x_b2  = sin(2*pi*50*t_b2) + 0.3*sin(2*pi*200*t_b2) + 0.5*randn(size(t_b2));

% TODO: Вычислить PSD через pwelch (перекрытие 50%, окно Ханна)
% [pxx, f_psd] = pwelch(x_b2, hann(256), 128, 512, fs_b2)
[pxx, f_psd] = ???;

% Обычный FFT для сравнения
N_b2  = length(x_b2);
X_b2  = fft(x_b2);
f_b2  = (0:N_b2/2-1)*fs_b2/N_b2;
psd_fft = abs(X_b2(1:N_b2/2)).^2 / (fs_b2*N_b2);

figure('Name', 'Б2: Сравнение FFT и Welch PSD');
semilogy(f_b2, psd_fft, 'b', 'LineWidth',0.5); hold on;
semilogy(f_psd, pxx, 'r', 'LineWidth',2);
legend('Обычный |FFT|²', 'Welch PSD (сглаженный)');
xlabel('Частота, Гц'); ylabel('PSD, В²/Гц');
title('Оценка спектральной плотности мощности');
xlim([0 300]); grid on;

%% ════════════════════════════════════════════════════════════
%% РАЗДЕЛ В: ДПФ и обратное ДПФ
%% ════════════════════════════════════════════════════════════

fprintf('\n--- РАЗДЕЛ В1: Фильтрация в частотной области ---\n');

fs_v = 1000; T_v = 1;
t_v  = (0:1/fs_v:T_v-1/fs_v);
N_v  = length(t_v);
x_v  = sin(2*pi*50*t_v) + sin(2*pi*200*t_v) + 0.5*randn(1,N_v);

% TODO: Прямое ДПФ
X_v = fft(x_v);

% TODO: Обнуление частот выше 100 Гц (полосовой режектор 150-250 Гц)
% Подсказка: определить индексы частот, соответствующих 150-250 Гц
f_v_axis = (0:N_v-1)*fs_v/N_v;
X_filtered = X_v;
% TODO: X_filtered(индексы 150-250 Гц) = 0; (и симметричные)
idx_reject = ???;  % find(f_v_axis >= 150 & f_v_axis <= 250)
X_filtered([idx_reject, N_v-idx_reject+2]) = 0;

% TODO: Обратное ДПФ — восстановить сигнал
x_restored = real(ifft(X_filtered));

% Оценить SNR: сравнить с чистым сигналом 50 Гц
x_clean_v = sin(2*pi*50*t_v);
signal_power = mean(x_clean_v.^2);
noise_power  = mean((x_restored - x_clean_v).^2);
snr_db = 10*log10(signal_power / (noise_power + eps));

figure('Name', 'В1: Фильтрация в частотной области');
subplot(3,1,1);
plot(t_v, x_v); title('Исходный зашумлённый сигнал'); grid on;
xlabel('Время, с'); ylabel('x(t)');

subplot(3,1,2);
f_half_v = f_v_axis(1:N_v/2);
plot(f_half_v, abs(X_v(1:N_v/2))*2/N_v, 'b'); hold on;
plot(f_half_v, abs(X_filtered(1:N_v/2))*2/N_v, 'r--');
legend('До фильтрации', 'После (частотная область)');
title('Спектры: режекция 150-250 Гц'); grid on;
xlabel('Частота, Гц');

subplot(3,1,3);
plot(t_v, x_restored, 'r', 'LineWidth',1.5);
title(sprintf('Восстановленный сигнал | SNR = %.2f дБ', snr_db));
grid on; xlabel('Время, с');

fprintf('SNR после фильтрации: %.2f дБ\n', snr_db);

%% В2: Спектрограмма чирп-сигнала
fprintf('\n--- РАЗДЕЛ В2: Спектрограмма ---\n');

fs_ch = 2000; T_ch = 2;
t_ch  = (0:1/fs_ch:T_ch-1/fs_ch);

% TODO: Сгенерировать chirp сигнал: от 10 Гц до 500 Гц за 2 секунды
% chirp(t_ch, f0, T_ch, f1) — линейный чирп
x_chirp = ???;   % chirp(t_ch, 10, T_ch, 500)

figure('Name', 'В2: Спектрограмма чирп-сигнала');
% TODO: Построить спектрограмму через spectrogram()
% spectrogram(x_chirp, hann(256), 128, 512, fs_ch, 'yaxis')
spectrogram(???, 'yaxis');
title('Спектрограмма линейного чирп-сигнала (10→500 Гц)');
colorbar; ylabel(colorbar, 'дБ');

%% ════════════════════════════════════════════════════════════
%% РАЗДЕЛ Г: Анализ сигнала датчика АСУТП
%% ════════════════════════════════════════════════════════════

fprintf('\n--- РАЗДЕЛ Г: Анализ сигнала датчика АСУТП ---\n');

% Загрузить данные (запустите lab1_8_generate_data.m если файл отсутствует)
if ~exist('sensor_data.mat','file')
    fprintf('Запустите lab1_8_generate_data.m для создания sensor_data.mat\n');
    return;
end
load('sensor_data.mat');  % sensor_signal, fs_s, t_s

%% Г1: Визуализация и предварительный анализ
figure('Name', 'Г: Сигнал датчика температуры');
subplot(2,1,1);
plot(t_s, sensor_signal, 'b', 'LineWidth',0.5);
xlabel('Время, с'); ylabel('Температура, °C');
title('Сигнал датчика (с помехами)'); grid on;

% TODO: Вычислить и построить спектр через pwelch
[pxx_s, f_psd_s] = pwelch(sensor_signal, hann(512), 256, 1024, fs_s);
subplot(2,1,2);
plot(f_psd_s, 10*log10(pxx_s));
xlabel('Частота, Гц'); ylabel('PSD, дБ/Гц');
title('Спектральная плотность мощности (Welch)');
xlim([0 300]); grid on;

%% Г2: Найти частоты помех
% TODO: Найти пики в спектре — это частоты помех
% Подсказка: findpeaks(pxx_s, f_psd_s, 'MinPeakHeight', ...)
[pk_vals, pk_freqs] = findpeaks(pxx_s, f_psd_s, 'MinPeakHeight', ???, ...
    'MinPeakDistance', 10);

% Выбрать значимые пики (выше шумового уровня)
% TODO: Отфильтровать пики выше средней мощности шума
freq_noise = ???;    % вектор найденных частот помех

fprintf('Обнаруженные частоты помех: ');
fprintf('%.1f Гц ', freq_noise);
fprintf('\n');

%% Г3: SNR до фильтрации
% Оценить SNR как отношение в полосе полезного сигнала (0-1 Гц) к помехам
% TODO: Вычислить snr_before через сравнение мощностей
snr_before = ???;   % число в дБ

%% Г4: Спроектировать и применить режекторный фильтр
% TODO: Для каждой найденной частоты создать режекторный фильтр (iirnotch)
% и последовательно применить к сигналу через filtfilt
sensor_filtered = sensor_signal;
for fi = 1:length(freq_noise)
    f_notch   = freq_noise(fi);
    w_notch   = f_notch / (fs_s/2);    % Нормированная частота
    bw_notch  = w_notch / 35;          % Добротность Q ≈ 35
    % TODO: [b_n, a_n] = iirnotch(w_notch, bw_notch);
    [b_n, a_n] = ???;
    % TODO: sensor_filtered = filtfilt(b_n, a_n, sensor_filtered);
    sensor_filtered = ???;
end

%% Г5: SNR после фильтрации
snr_after = ???;    % число в дБ (аналогично snr_before, но для sensor_filtered)

figure('Name', 'Г: Результат фильтрации');
plot(t_s, sensor_signal, 'b', 'LineWidth',0.5); hold on;
plot(t_s, sensor_filtered, 'r', 'LineWidth',1.5);
legend('До фильтрации', 'После режекторного фильтра');
xlabel('Время, с'); ylabel('Температура, °C');
title(sprintf('Сигнал датчика | SNR: %.1f → %.1f дБ', snr_before, snr_after));
grid on;

fprintf('\n=== ИТОГ ===\n');
fprintf('SNR до фильтрации:  %.2f дБ\n', snr_before);
fprintf('SNR после:          %.2f дБ\n', snr_after);
fprintf('Улучшение:          %.2f дБ\n', snr_after - snr_before);
fprintf('\nЗапустите lab1_8_validator.m для автопроверки.\n');
