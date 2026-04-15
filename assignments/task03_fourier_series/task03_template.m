%% ЗАДАНИЕ 3: Разложение в ряд Фурье. Явление Гиббса.
%% ФИО: ___________________ Группа: ___________

clear; close all; clc;

%% --- Параметры (не изменять!) ---
T    = 1.0;                     % Период, с
A    = 1.0;                     % Амплитуда
fs   = 5000;                    % Частота дискретизации
t    = 0:1/fs:2*T-1/fs;        % Два периода
N_list = [1, 5, 15, 51, 201];  % Число гармоник

%% --- ШАГ 1: Идеальный прямоугольный сигнал ---
x_ideal = A * square(2*pi/T * t);

%% --- ШАГ 2: Синтез ряда Фурье для каждого N ---
% Формула для прямоугольного сигнала амплитудой A:
%   x_N(t) = (4A/π) * Σ_{k=1,3,5,...,N} (1/k)*sin(2π*k*t/T)
%
% Выходные переменные:
%   fourier_coeffs — вектор длины 5 (RMSE при каждом N)
%   x_N_51         — вектор синтезированного сигнала при N=51 гармоник

fourier_coeffs = zeros(1, 5);   % RMSE для N_list
x_N_last       = zeros(1, length(t));

figure('Name', 'Задание 3: Ряд Фурье и явление Гиббса');
colors = {'#d62728','#ff7f0e','#2ca02c','#1f77b4','#9467bd'};

for i = 1:5
    N_harm = N_list(i);
    
    % TODO: Вычислить x_N — сумму нечётных гармоник до N
    x_sum = zeros(1, length(t));
    for k = 1 : 2 : N_harm
        % TODO: x_sum = x_sum + (1/k)*sin(2*pi*k*t/T)
        x_sum = x_sum + ???;
    end
    x_N = (4*A/pi) * x_sum;
    
    % TODO: Вычислить RMSE относительно идеального сигнала
    fourier_coeffs(i) = sqrt(mean((x_N - x_ideal).^2));
    
    if N_harm == 51
        x_N_51 = x_N;  % Сохранить для N=51
    end
    
    subplot(5,1,i);
    plot(t, x_ideal, 'k--', 'LineWidth', 0.5); hold on;
    plot(t, x_N, 'Color', colors{i}, 'LineWidth', 1.3);
    ylabel(sprintf('N=%d', N_harm));
    title(sprintf('N = %d гармоник | RMSE = %.4f', N_harm, fourier_coeffs(i)));
    grid on; ylim([-1.5 1.5]);
    if i==5; xlabel('Время, с'); end
end
sgtitle('Разложение прямоугольного сигнала в ряд Фурье');

%% --- ШАГ 3: Гиббс-анализ ---
% Отображение выброса вблизи фронта (N=201)
N_gibbs = 201;
x_gibbs = zeros(1, length(t));
for k = 1:2:N_gibbs
    x_gibbs = x_gibbs + (1/k)*sin(2*pi*k*t/T);
end
x_gibbs = (4*A/pi)*x_gibbs;

figure('Name', 'Задание 3: Явление Гиббса (крупный план)');
t_mask = t >= 0.95 & t <= 1.05;  % Окрестность скачка
plot(t(t_mask), x_ideal(t_mask), 'k--', 'LineWidth', 2); hold on;
plot(t(t_mask), x_gibbs(t_mask), 'r', 'LineWidth', 1.5);
yline(1.0, 'b:', '1.0 (теор.)');
yline(1.089, 'g:', '1.089 (+8.9% Гиббс)');
xlabel('Время, с'); ylabel('Амплитуда');
title(sprintf('Явление Гиббса: N=%d. Выброс ≈ 8.9%% от скачка', N_gibbs));
legend('Идеальный', 'Ряд Фурье (N=201)'); grid on;

fprintf('\n=== РЕЗУЛЬТАТЫ ===\n');
fprintf('N-гарм | RMSE\n');
for i=1:5
    fprintf('  %3d   | %.5f\n', N_list(i), fourier_coeffs(i));
end
fprintf('\nЗапустите task03_grader.m для проверки.\n');
