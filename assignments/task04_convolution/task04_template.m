%% ЗАДАНИЕ 4: Свёртка сигналов — conv() и вручную
%% ФИО: ___________________ Группа: ___________

clear; close all; clc;

%% --- Параметры (не изменять!) ---
fs = 1000;              % Частота дискретизации, Гц
T  = 0.1;               % Длительность каждого сигнала, с
t  = 0:1/fs:T-1/fs;
N  = length(t);

% Два сигнала
x1 = sin(2*pi*20*t) .* (t < 0.05);        % Синус с обрезкой
x2 = exp(-50*t) .* double(t >= 0);         % Экспоненциальный спад

%% --- ЧАСТЬ А: Свёртка через conv() ---
% TODO: y_conv = conv(x1, x2) / fs
% Деление на fs — нормировка к непрерывной свёртке
y_conv = ???;

% Временная ось результата (длина = 2N-1)
t_conv = (0 : length(y_conv)-1) / fs;

%% --- ЧАСТЬ Б: Свёртка вручную (через цикл) ---
N1 = length(x1);
N2 = length(x2);
N_out = N1 + N2 - 1;
y_manual = zeros(1, N_out);

% TODO: Реализовать линейную свёртку через вложенный цикл
% y[n] = Σ_{k=0}^{N1-1} x1[k] * x2[n-k]   (при 0 <= n-k <= N2-1)
for n = 1 : N_out
    for k = 1 : N1
        m = n - k + 1;              % m = n - k (1-indexed)
        if m >= 1 && m <= N2
            % TODO: y_manual(n) = y_manual(n) + x1(k)*x2(m)
            y_manual(n) = y_manual(n) + ???;
        end
    end
end
y_manual = y_manual / fs;           % Нормировка

%% --- ЧАСТЬ В: Проверка совпадения ---
max_diff = max(abs(y_conv - y_manual));
fprintf('Максимальное расхождение conv() и вручную: %.2e\n', max_diff);

%% --- Графики ---
figure('Name', 'Задание 4: Свёртка сигналов');

subplot(3,1,1);
plot(t, x1, 'b', 'LineWidth',1.5); hold on;
plot(t, x2, 'r', 'LineWidth',1.5);
legend('x_1(t)', 'x_2(t)'); grid on;
xlabel('Время, с'); ylabel('Амплитуда');
title('Исходные сигналы');

subplot(3,1,2);
plot(t_conv, y_conv, 'b', 'LineWidth',2); hold on;
plot(t_conv, y_manual, 'r--', 'LineWidth',1.2);
legend('conv()', 'Вручную (цикл)');
xlabel('Время, с'); ylabel('y(t)');
title(sprintf('Свёртка y(t) = x_1 * x_2 | Расхождение = %.2e', max_diff));
grid on;

subplot(3,1,3);
plot(t_conv, abs(y_conv - y_manual), 'k', 'LineWidth',1);
xlabel('Время, с'); ylabel('|Ошибка|');
title('Разность conv() и ручного метода');
grid on;

fprintf('Запустите task04_grader.m для проверки.\n');
