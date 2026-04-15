%% ============================================================
%% lab2_7_template.m — Шаблон для студента
%% Лабораторная работа 2.7: Импульсно-модулированные сигналы
%% ============================================================
%% ФИО: ___________________________________
%% Группа: ________________________________
%% Дата: __________________________________

clear; close all; clc;
rng(2025);  % Не изменять!

%% ════════════════════════════════════════════════════════════
%% РАЗДЕЛ А: Амплитудно-импульсная модуляция (PAM)
%% ════════════════════════════════════════════════════════════

%% А1: Идеальная выборка и алиасинг
% ─────────────────────────────────
fprintf('--- РАЗДЕЛ А1: Дискретизация ---\n');

fs_m  = 1000;           % Частота дискретизации «аналогового» сигнала
T_m   = 1;              % Длительность, с
t_m   = 0:1/fs_m:T_m-1/fs_m;
N_m   = length(t_m);

% Модулирующий сигнал (две частоты: 5 и 12 Гц)
m_t   = cos(2*pi*5*t_m) + 0.5*cos(2*pi*12*t_m);

% Три частоты дискретизации
fs_vals = [50, 30, 100];   % Гц: выполнена, нарушена, перекрытие
snr_vals = zeros(1,3);

figure('Name', 'А1: Сравнение дискретизации при разных fs');
for i = 1:3
    fs_i = fs_vals(i);
    
    % TODO: Выбрать отсчёты из m_t через индексы (каждый fs_m/fs_i отсчёт)
    step_i   = round(fs_m / fs_i);
    t_sampled = t_m(1:step_i:end);
    m_sampled = m_t(???);   % m_t(1:step_i:end)
    
    % TODO: Восстановить через линейную интерполяцию
    % m_restored = interp1(t_sampled, m_sampled, t_m, 'linear', 'extrap')
    m_restored = interp1(???);
    
    % TODO: Вычислить SNR (дБ) между m_t и m_restored
    P_sig = mean(m_t.^2);
    P_err = mean((m_t - m_restored).^2);
    snr_vals(i) = 10*log10(P_sig / (P_err + eps));
    
    subplot(3,1,i);
    plot(t_m, m_t, 'k', 'LineWidth',0.5); hold on;
    stem(t_sampled, m_sampled, 'b', 'filled', 'MarkerSize',4);
    plot(t_m, m_restored, 'r--');
    title(sprintf('fs = %d Гц | SNR = %.1f дБ %s', fs_i, snr_vals(i), ...
        iif(fs_i < 2*12, '⚠ АЛИАСИНГ', '✓')));
    legend('m(t)', 'Отсчёты', 'Восстановленный');
    grid on; xlabel('Время, с');
end

snr_fs1  = snr_vals(1);   % fs = 50 Гц
snr_fs2  = snr_vals(2);   % fs = 30 Гц (алиасинг)
snr_fs3  = snr_vals(3);   % fs = 100 Гц

fprintf('SNR: fs=50: %.1f дБ | fs=30: %.1f дБ | fs=100: %.1f дБ\n', ...
    snr_fs1, snr_fs2, snr_fs3);

%% А2: PAM с естественной выборкой
% ─────────────────────────────────
fprintf('\n--- РАЗДЕЛ А2: PAM ---\n');

fs_pam = 50;            % Частота дискретизации PAM, Гц
tau_pam = 1/fs_pam/2;   % Длительность импульса (скважность = 2)

% Формировать периодическую последовательность прямоугольных импульсов
p_T = zeros(1, N_m);
step_pam = round(fs_m / fs_pam);
for k = 1:step_pam:N_m
    idx_end = min(k + round(tau_pam*fs_m) - 1, N_m);
    p_T(k:idx_end) = 1;
end

% TODO: PAM = m(t) * p_T(t)
x_PAM = ???;   % m_t .* p_T

% TODO: Спектр PAM
N_pam = N_m;
X_PAM = fft(x_PAM, N_pam);
f_pam = (0:N_pam/2-1)*fs_m/N_pam;
X_PAM_mag = abs(X_PAM(1:N_pam/2)) * 2/N_pam;

figure('Name', 'А2: PAM с естественной выборкой');
subplot(3,1,1); plot(t_m, m_t, 'b'); title('m(t) — модулирующий сигнал'); grid on;
subplot(3,1,2); plot(t_m, p_T, 'k'); title('p_T(t) — последовательность импульсов'); grid on;
subplot(3,1,3); plot(t_m, x_PAM, 'r'); title('x_{PAM}(t)'); grid on;
xlabel('Время, с');

figure('Name', 'А2: Спектр PAM');
plot(f_pam, X_PAM_mag);
xlabel('Частота, Гц'); ylabel('|X_{PAM}(f)|');
title(sprintf('Спектр PAM (fs=%d Гц). Ожидаются полосы вокруг n·%d Гц', fs_pam, fs_pam));
xlim([0 300]); grid on;

%% ════════════════════════════════════════════════════════════
%% РАЗДЕЛ Б: Широтно-импульсная модуляция (ШИМ / PWM)
%% ════════════════════════════════════════════════════════════

fprintf('\n--- РАЗДЕЛ Б1: ШИМ ---\n');

fs_pwm   = 5000;        % Высокая частота дискретизации
T_pwm    = 1;
t_pwm    = 0:1/fs_pwm:T_pwm-1/fs_pwm;
f_carr   = 100;         % Частота несущего треугольного сигнала
fm_pwm   = 5;           % Частота модулирующего сигнала

% Модулирующий сигнал (скалирован к [-1, 1])
m_pwm    = 0.8 * sin(2*pi*fm_pwm*t_pwm);

% TODO: Несущий треугольный сигнал: sawtooth(2*pi*f_carr*t_pwm, 0.5)
carrier_pwm = ???;

% TODO: ШИМ через сравнение:
% pwm_signal = m_pwm > carrier_pwm → 1, иначе 0
% Использовать double(m_pwm > carrier_pwm)
pwm_signal = ???;

% TODO: Восстановить m(t) через ФНЧ Баттерворта (fc = fm_pwm*2 = 10 Гц)
fc_lpf_pwm = 2*fm_pwm / (fs_pwm/2);  % Нормированная частота
[b_pw, a_pw] = butter(5, fc_lpf_pwm);
% TODO: m_restored_pwm = filtfilt(b_pw, a_pw, double(pwm_signal))
m_restored_pwm = ???;

figure('Name', 'Б1: Широтно-импульсная модуляция');
subplot(4,1,1); plot(t_pwm, m_pwm, 'b'); title('m(t): модулирующий'); grid on;
subplot(4,1,2); plot(t_pwm, carrier_pwm, 'k'); title('Несущий треугольник'); grid on;
subplot(4,1,3);
t_show = t_pwm < 0.1;   % Показать первые 100 мс
plot(t_pwm(t_show), pwm_signal(t_show), 'r');
title('ШИМ сигнал (первые 100 мс)'); ylim([-0.2 1.2]); grid on;
subplot(4,1,4);
plot(t_pwm, m_pwm, 'b--'); hold on;
plot(t_pwm, m_restored_pwm, 'r', 'LineWidth',1.5);
legend('m(t) оригинал', 'Восстановленный через ФНЧ');
title('Восстановление сигнала из ШИМ'); grid on;
xlabel('Время, с');

%% Б2: КНИ (THD) ШИМ сигнала
fprintf('\n--- РАЗДЕЛ Б2: КНИ ШИМ ---\n');

N_pwm  = length(pwm_signal);
X_pwm  = fft(pwm_signal) / N_pwm;
f_pwm  = (0:N_pwm-1)*fs_pwm/N_pwm;

% Найти амплитуды гармоник: f_m * 1, 2, 3, ...
max_harm = 20;
A_harms  = zeros(1, max_harm);
for k = 1:max_harm
    f_k  = k * fm_pwm;
    idx  = round(f_k / (fs_pwm/N_pwm)) + 1;
    if idx <= N_pwm/2
        A_harms(k) = 2 * abs(X_pwm(idx));
    end
end
A1 = A_harms(1);

% TODO: КНИ = sqrt(sum(A_n^2, n=2..end)) / A1 * 100%
THD_pwm = ???;   % sqrt(sum(A_harms(2:end).^2)) / A1 * 100

fprintf('Амплитуды гармоник (1-20): ');
fprintf('%.3f ', A_harms(1:5));
fprintf('...\n');
fprintf('КНИ (THD): %.2f%%\n', THD_pwm);

%% ════════════════════════════════════════════════════════════
%% РАЗДЕЛ В: Фазо-импульсная модуляция (ФИМ / PPM)
%% ════════════════════════════════════════════════════════════

fprintf('\n--- РАЗДЕЛ В: ФИМ ---\n');

fs_ppm  = 50;           % Частота отсчётов, Гц
T_ppm   = 1;            % Длительность
t_base  = 0:1/fs_ppm:T_ppm-1/fs_ppm;   % Опорные моменты
Ts_ppm  = 1/fs_ppm;     % Период

% Значения модулирующего сигнала в моменты отсчётов
m_ppm   = sin(2*pi*5*t_base);   % Нормирован к [-1, 1]
delta_T = Ts_ppm / 3;            % Макс. сдвиг = 1/3 периода

% TODO: Вычислить фактические моменты прихода импульсов
% t_ppm_k = k*Ts_ppm + delta_T*m_ppm(k)
ppm_times = t_base + delta_T * m_ppm;  % ← уже вычислено, если m_ppm задан

% Построить ФИМ сигнал как набор импульсов
figure('Name', 'В: Фазо-импульсная модуляция');
subplot(3,1,1);
plot(t_base, m_ppm, 'b', 'LineWidth',1.5);
xlabel('Время, с'); ylabel('m(t)');
title('Модулирующий сигнал'); grid on;

subplot(3,1,2);
stem(t_base, t_base, 'k', 'filled', 'MarkerSize',5);  % Опорные позиции
hold on;
stem(ppm_times, ones(size(ppm_times)), 'r', 'filled', 'MarkerSize',5);
legend('Опорные позиции (без модуляции)', 'ФИМ позиции');
title('ФИМ: сдвиг импульсов пропорционален m(t)');
xlabel('Время, с'); grid on;

subplot(3,1,3);
% Сравнение трёх видов модуляции
t_all = t_m; step_50 = round(fs_m/50);
t_s50 = t_m(1:step_50:end);
m_s50 = m_t(1:step_50:end);
stem(t_s50, m_s50, 'b', 'filled', 'MarkerSize',5, 'DisplayName','PAM'); hold on;
plot(t_pwm, pwm_signal*max(m_t), 'k', 'LineWidth',0.3, 'DisplayName','ШИМ (огибающая)');
stem(ppm_times, ones(size(ppm_times))*max(m_t), 'r', 'filled', 'MarkerSize',4, 'DisplayName','ФИМ');
legend; xlabel('Время, с');
title('Сравнение: PAM, ШИМ, ФИМ');
grid on; xlim([0, 0.5]);

%% ════════════════════════════════════════════════════════════
%% РАЗДЕЛ Г: Моделирование канала с шумом
%% ════════════════════════════════════════════════════════════

fprintf('\n--- РАЗДЕЛ Г: Канал с шумом ---\n');

% Опорный сигнал (8 отсчётов за период 50 Гц синусоиды)
fs_ch2  = fs_m;
T_ch2   = 0.5;
t_ch2   = 0:1/fs_ch2:T_ch2-1/fs_ch2;
m_ch2   = sin(2*pi*10*t_ch2);  % 10 Гц

% PAM формирование
step_ch = round(fs_ch2/50);
p_T_ch  = zeros(1, length(t_ch2));
for k = 1:step_ch:length(t_ch2)
    idx_e = min(k+round(tau_pam*fs_ch2)-1, length(t_ch2));
    p_T_ch(k:idx_e) = 1;
end
x_PAM_ch = m_ch2 .* p_T_ch;

% Три уровня шума
snr_levels = [20, 10, 5];
rmse_vals  = zeros(1,3);
rmse_names = {'rmse_snr20','rmse_snr10','rmse_snr5'};

figure('Name', 'Г: PAM через зашумлённый канал');
for i = 1:3
    snr_i = snr_levels(i);
    
    % TODO: Добавить шум через awgn
    x_noisy_ch = awgn(???);   % awgn(x_PAM_ch, snr_i, 'measured')
    
    % TODO: ФНЧ для восстановления: butter(4, fc_norm) + filtfilt
    fc_norm_ch = (2*10) / (fs_ch2/2);
    [b_ch, a_ch] = butter(4, fc_norm_ch);
    m_recv = filtfilt(b_ch, a_ch, x_noisy_ch);
    
    % Выбрать отсчёты (в середине каждого периода PAM)
    t_samp_idx = round(step_ch/2):step_ch:length(t_ch2)-1;
    m_recv_samp_t = t_ch2(t_samp_idx);
    m_recv_samp   = m_recv(t_samp_idx);
    m_orig_samp   = m_ch2(t_samp_idx);
    
    % TODO: RMSE между восстановленными отсчётами и оригиналом
    rmse_vals(i) = sqrt(mean((m_recv_samp - m_orig_samp).^2));
    
    subplot(3,1,i);
    plot(t_ch2, m_ch2, 'k', 'LineWidth',0.5); hold on;
    plot(t_ch2, x_noisy_ch, 'b', 'LineWidth',0.3);
    plot(t_ch2, m_recv, 'r', 'LineWidth',1.5);
    title(sprintf('SNR = %d дБ | RMSE = %.4f', snr_i, rmse_vals(i)));
    legend('Исходный', 'PAM+шум', 'Восстановленный');
    grid on; xlabel('Время, с');
end

rmse_snr20 = rmse_vals(1);
rmse_snr10 = rmse_vals(2);
rmse_snr5  = rmse_vals(3);

fprintf('\n=== ИТОГОВАЯ ТАБЛИЦА ===\n');
fprintf('SNR, дБ | RMSE\n');
fprintf('--------|------\n');
for i=1:3
    fprintf('   %3d  | %.5f\n', snr_levels(i), rmse_vals(i));
end

fprintf('\nЗапустите lab2_7_validator.m для автопроверки.\n');

%% Вспомогательная функция
function r = iif(cond, a, b)
    if cond; r=a; else; r=b; end
end
