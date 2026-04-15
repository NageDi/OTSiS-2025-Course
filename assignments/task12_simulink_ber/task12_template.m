%% ЗАДАНИЕ 12: Комплексное задание — MATLAB часть
%% Канал с шумом. Оценка BER — скрипт поддержки для Simulink-модели
%% ФИО: ___________________ Группа: ___________
%%
%% ПОРЯДОК ВЫПОЛНЕНИЯ:
%%   1. Запустить этот скрипт — создаёт параметры и входные данные
%%   2. Открыть task12_channel.slx в Simulink и запустить модель
%%   3. Запустить task12_grader.m для проверки переменных workspace

clear; close all; clc;

%% ════════════════════════════════════════════════════════════
%% ЧАСТЬ А: Генерация бинарного сообщения
%% ════════════════════════════════════════════════════════════
rng(2025);          % Не изменять!

N_bits   = 1000;    % Длина сообщения
Rb       = 1000;    % Битовая скорость, бит/с
Ts_bit   = 1/Rb;    % Длительность одного бита
fs_sim   = 10000;   % Частота дискретизации модели
spb      = fs_sim / Rb;   % Отсчётов на бит (samples per bit = 10)

% TODO: Сгенерировать бинарное сообщение (0/1)
% bits = randi([0, 1], 1, N_bits)
bits = ???;

% TODO: Сформировать биполярный NRZ сигнал: +1 for '1', -1 for '0'
% NRZ сигнал: x_nrz[n] = кажд. бит повторяется spb раз
x_nrz_bits = 2*double(bits) - 1;           % +1/-1
x_nrz = repelem(x_nrz_bits, spb);           % Расширение до fs_sim
t_nrz = (0:length(x_nrz)-1) / fs_sim;      % Временная ось

% Параметры несущей
fc    = 2000;       % Частота несущей, Гц
A_c12 = 1;          % Амплитуда несущей

%% ════════════════════════════════════════════════════════════
%% ЧАСТЬ Б: BPSK модуляция (вручную, для проверки)
%% ════════════════════════════════════════════════════════════
t_full = (0:length(x_nrz)-1) / fs_sim;

% TODO: BPSK: x_bpsk = A_c12 * x_nrz .* cos(2*pi*fc*t_full)
x_bpsk = ???;

%% ════════════════════════════════════════════════════════════
%% ЧАСТЬ В: Добавление шума (AWGN) при разных Eb/N0
%% ════════════════════════════════════════════════════════════
EbN0_dB_list = [0, 2, 4, 6, 8, 10];    % Eb/N0 в дБ
BER_measured  = zeros(1, length(EbN0_dB_list));
BER_theory    = zeros(1, length(EbN0_dB_list));

for i = 1:length(EbN0_dB_list)
    EbN0_dB  = EbN0_dB_list(i);
    EbN0_lin = 10^(EbN0_dB/10);
    
    % TODO: Добавить AWGN через awgn() с 'measured' мощностью
    % x_noisy = awgn(x_bpsk, EbN0_dB + 10*log10(spb/2), 'measured')
    x_noisy = awgn(???);
    
    % BPSK демодуляция: умножить на несущую + ФНЧ + решающее устройство
    x_demod = x_noisy .* (2*cos(2*pi*fc*t_full));
    
    % ФНЧ (скользящее среднее по spb отсчётам)
    x_lp    = conv(x_demod, ones(1,spb)/spb, 'same');
    
    % Выборка в середине каждого бита
    samp_idx = round(spb/2) : spb : length(x_lp);
    rx_syms  = x_lp(samp_idx(1:N_bits));
    
    % Принятое решение: > 0 → 1, < 0 → 0
    bits_rx  = double(rx_syms > 0);
    
    % TODO: Подсчёт BER — доля неправильно принятых бит
    % BER_measured(i) = sum(bits ~= bits_rx) / N_bits
    BER_measured(i) = ???;
    
    % Теоретический BER для BPSK: erfc(sqrt(Eb/N0)) / 2
    % TODO: BER_theory(i) = erfc(sqrt(EbN0_lin)) / 2
    BER_theory(i) = ???;
end

%% ════════════════════════════════════════════════════════════
%% Графики
%% ════════════════════════════════════════════════════════════

figure('Name', 'Задание 12: BPSK канал с шумом', 'Position',[50 50 1100 700]);

% NRZ и BPSK сигнал (первые 5 бит)
show_t = t_full < 5*Ts_bit;
subplot(3,2,1);
plot(t_nrz(show_t)*1000, x_nrz(show_t), 'b', 'LineWidth', 2);
xlabel('Время, мс'); ylabel('Амплитуда');
title('NRZ сигнал (5 бит)'); grid on; ylim([-1.5 1.5]);

subplot(3,2,2);
plot(t_full(show_t)*1000, x_bpsk(show_t), 'r', 'LineWidth', 1.2);
xlabel('Время, мс'); ylabel('Амплитуда');
title(sprintf('BPSK (fc=%d Гц, 5 бит)', fc)); grid on;

% Зашумлённый сигнал при Eb/N0 = 6 дБ
idx_6 = find(EbN0_dB_list == 6);
x_noisy_demo = awgn(x_bpsk, 6 + 10*log10(spb/2), 'measured');
subplot(3,2,3);
plot(t_full(show_t)*1000, x_noisy_demo(show_t), 'm', 'LineWidth', 0.8);
xlabel('Время, мс'); ylabel('Амплитуда');
title('BPSK + шум (Eb/N0=6 дБ)'); grid on;

% Спектр BPSK сигнала
N12  = length(x_bpsk);
X12  = fft(x_bpsk, N12);
f12  = (0:N12/2-1)*fs_sim/N12;
subplot(3,2,4);
plot(f12, abs(X12(1:N12/2))*2/N12, 'k', 'LineWidth', 0.8);
xlabel('Частота, Гц'); ylabel('|X(f)|');
title('Спектр BPSK сигнала'); grid on;
xlim([0 5000]);

% Кривая BER vs Eb/N0
subplot(3,2,[5 6]);
semilogy(EbN0_dB_list, BER_theory, 'b-', 'LineWidth', 2); hold on;
semilogy(EbN0_dB_list, max(BER_measured, 1e-5), 'ro--', 'LineWidth', 1.5, 'MarkerSize', 8);
legend('Теоретический BER (BPSK)', 'Измеренный BER');
xlabel('Eb/N0, дБ'); ylabel('BER');
title('Кривая BER — BPSK канал с AWGN');
grid on; ylim([1e-5 1]); xlim([0 12]);
xline(6,'g--','Eb/N0=6 дБ');

sgtitle('Задание 12: Моделирование BPSK канала с шумом');

%% ════════════════════════════════════════════════════════════
%% Вывод результатов
%% ════════════════════════════════════════════════════════════
fprintf('\n=== РЕЗУЛЬТАТЫ ===\n');
fprintf('%-12s %-14s %-14s\n','Eb/N0, дБ','BER изм.','BER теор.');
fprintf('%-12s %-14s %-14s\n','----------','--------','----------');
for i = 1:length(EbN0_dB_list)
    fprintf('   %-9d %-14.4e %-14.4e\n', EbN0_dB_list(i), BER_measured(i), BER_theory(i));
end
fprintf('\nЗапустите task12_grader.m для итоговой проверки.\n');

%% ════════════════════════════════════════════════════════════
%% Инструкция по Simulink-модели
%% ════════════════════════════════════════════════════════════
fprintf('\n═══════════════════════════════════════════════════════\n');
fprintf(' ИНСТРУКЦИЯ ПО SIMULINK МОДЕЛИ:\n');
fprintf('  1. Открыть task12_channel.slx\n');
fprintf('  2. В блоке «Random Integer» установить N_bits=%d\n', N_bits);
fprintf('  3. В блоке «AWGN Channel» установить EbN0 = 6 дБ\n');
fprintf('  4. Запустить симуляцию (Ctrl+T)\n');
fprintf('  5. Снять показания блока «BER Display» и записать в BER_simulink\n');
fprintf('  6. Присвоить: BER_simulink = <значение из блока>;\n');
fprintf('  7. Запустить task12_grader.m\n');
fprintf('═══════════════════════════════════════════════════════\n');
