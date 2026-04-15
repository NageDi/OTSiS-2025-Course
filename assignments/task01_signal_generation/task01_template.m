%% ЗАДАНИЕ 1: Генерация базовых сигналов
%% Синус, прямоугольник, пила, ступенька
%% ФИО: ___________________ Группа: ___________

clear; close all; clc;

%% --- Параметры (не изменять!) ---
fs   = 1000;        % Частота дискретизации, Гц
T    = 1.0;         % Длительность, с
t    = 0:1/fs:T-1/fs;
f0   = 5;           % Частота сигналов, Гц
A    = 2;           % Амплитуда

%% --- ШАГ 1: Синусоидальный сигнал ---
% TODO: x_sin = A * sin(2*pi*f0*t)
x_sin = ???;

%% --- ШАГ 2: Прямоугольный сигнал ---
% TODO: x_rect = A * square(2*pi*f0*t)
x_rect = ???;

%% --- ШАГ 3: Пилообразный сигнал ---
% TODO: x_saw = A * sawtooth(2*pi*f0*t)
x_saw = ???;

%% --- ШАГ 4: Единичная ступенька ---
% u(t) = 0 при t < 0.3, u(t) = A при t >= 0.3
% TODO: x_step = A * double(t >= 0.3)
x_step = ???;

%% --- Построение графиков ---
figure('Name', 'Задание 1: Базовые сигналы', 'Position', [100 100 900 600]);

subplot(4,1,1);
plot(t, x_sin, 'b', 'LineWidth', 1.5);
xlabel('Время, с'); ylabel('Амплитуда');
title(sprintf('Синус: A=%.0f, f=%.0f Гц', A, f0));
grid on; ylim([-A*1.5 A*1.5]);

subplot(4,1,2);
plot(t, x_rect, 'r', 'LineWidth', 1.5);
xlabel('Время, с'); ylabel('Амплитуда');
title(sprintf('Прямоугольный: A=%.0f, f=%.0f Гц', A, f0));
grid on; ylim([-A*1.5 A*1.5]);

subplot(4,1,3);
plot(t, x_saw, 'm', 'LineWidth', 1.5);
xlabel('Время, с'); ylabel('Амплитуда');
title(sprintf('Пилообразный: A=%.0f, f=%.0f Гц', A, f0));
grid on; ylim([-A*1.5 A*1.5]);

subplot(4,1,4);
plot(t, x_step, 'g', 'LineWidth', 1.5);
xlabel('Время, с'); ylabel('Амплитуда');
title('Единичная ступенька (A=2, скачок в t=0.3 с)');
grid on; ylim([-0.5 A*1.5]);

sgtitle('Задание 1: Основные виды сигналов');

fprintf('Запустите task01_grader.m для автопроверки.\n');
