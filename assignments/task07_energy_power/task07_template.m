%% ЗАДАНИЕ 7: Энергия и мощность сигнала. Энергетический спектр.
%% ФИО: ___________________ Группа: ___________

clear; close all; clc;

%% --- Параметры (не изменять!) ---
fs = 2000;              % Частота дискретизации, Гц
T  = 2.0;               % Длительность, с
t  = 0:1/fs:T-1/fs;
N  = length(t);

%% --- Сигналы ---
% Сигнал 1: конечной энергии (импульс) — затухающий синус
x_energy = exp(-3*t) .* sin(2*pi*50*t);    % E < ∞

% Сигнал 2: конечной мощности (периодический) — синус
x_power  = 2*sin(2*pi*30*t) + sin(2*pi*90*t);  % P < ∞

%% --- ЧАСТЬ 1: Разностная оценка энергии (численно) ---
% E = Σ |x[n]|² * (1/fs)   — интеграл Σ |x|² dt
% TODO: E_energy = sum(x_energy.^2) / fs
E_energy = ???;

% TODO: E_power = sum(x_power.^2) / fs  (бесконечная для чисто периодич.)
E_power  = sum(x_power.^2) / fs;   % Но мы считаем на отрезке T

%% --- ЧАСТЬ 2: Средняя мощность периодического сигнала ---
% P = (1/T) * Σ |x[n]|² / fs
% TODO: P_power = sum(x_power.^2) / (fs * T)
P_power  = ???;

% Теоретическое значение мощности: P = A1²/2 + A2²/2
P_theory = 2^2/2 + 1^2/2;

%% --- ЧАСТЬ 3: Энергетический спектр через |X(f)|² ---
% Спектральная плотность энергии (теорема Парсеваля):
% S_E(f) = |X(f)|² / N² * (N/fs)
X_energy = fft(x_energy, N);
% TODO: ESD = (|X_energy|.^2) / (fs * N)   — спект. плотн. энергии
ESD      = ???;
f_axis   = (0:N/2-1) * fs/N;
ESD_half = ESD(1:N/2) * 2;         % Односторонний спектр

% Парсеваль: сумма E из спектра
E_parseval = sum(ESD) / fs;         % Проверка

%% --- ЧАСТЬ 4: Спектральная плотность мощности (PSD) ---
X_power  = fft(x_power, N);
% TODO: PSD = |X_power|.^2 / (fs * N * T)
PSD      = ???;
PSD_half = PSD(1:N/2) * 2;         % Односторонний

%% --- Графики ---
figure('Name', 'Задание 7: Энергия и мощность', 'Position',[50 50 1000 700]);

subplot(2,3,1);
plot(t, x_energy,'b','LineWidth',1.5);
xlabel('Время, с'); ylabel('x(t)');
title('x₁(t): затухающий синус (конечная энергия)'); grid on;

subplot(2,3,2);
plot(f_axis, ESD_half,'r','LineWidth',1.5);
xlabel('Частота, Гц'); ylabel('|X(f)|²/f_s·N');
title(sprintf('Спект. плотность энергии (ESD)\nE = %.4f Дж', E_energy)); grid on;
xlim([0 200]);

subplot(2,3,3);
bar([E_energy, E_parseval], 0.5,'FaceColor',[0.2 0.5 0.8]);
set(gca,'XTickLabel',{'E (числ.)','E (Парсеваль)'}); ylabel('Энергия');
title(sprintf('Проверка теоремы Парсеваля\nОшибка: %.2e',abs(E_energy-E_parseval)));
grid on;

subplot(2,3,4);
plot(t, x_power,'m','LineWidth',1.2);
xlabel('Время, с'); ylabel('x(t)');
title('x₂(t): периодический (конечная мощность)'); grid on;

subplot(2,3,5);
plot(f_axis, PSD_half,'g','LineWidth',1.5);
xlabel('Частота, Гц'); ylabel('PSD');
title(sprintf('Спектральная плотность мощности (PSD)\nP = %.4f Вт', P_power)); grid on;
xlim([0 200]);

subplot(2,3,6);
bar([P_power, P_theory], 0.5,'FaceColor',[0.2 0.7 0.3]);
set(gca,'XTickLabel',{'P (числ.)','P (теор.)'}); ylabel('Мощность, Вт');
title(sprintf('Сравнение P числ. и теор.\nОшибка: %.2e',abs(P_power-P_theory)));
grid on;

sgtitle('Задание 7: Энергия, мощность, спектральные плотности');

fprintf('\n=== РЕЗУЛЬТАТЫ ===\n');
fprintf('Энергия x1:      E = %.4f Дж\n', E_energy);
fprintf('Энергия (Парс.): E = %.4f Дж\n', E_parseval);
fprintf('Мощность x2:     P = %.4f Вт\n', P_power);
fprintf('Мощность (теор): P = %.4f Вт\n', P_theory);
fprintf('\nЗапустите task07_grader.m для проверки.\n');
