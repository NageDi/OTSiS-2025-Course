%% Лабораторная работа №3: Линейные системы и свёртка
% Курс: ОТСиС 2025
% Студент: _________________

%% 1. ПОДГОТОВКА
clear; clc; close all;

%% 2. ТЕОРИЯ: СВЁРТКА (CONVOLUTION)
% Выход системы y[n] = x[n] * h[n]
% В MATLAB: y = conv(x, h)

%% 3. ПРИМЕР СВЁРТКИ
x = [0 0 1 1 1 1 0 0];    % Вход
h = [0.33 0.33 0.33];     % Фильтр

y = conv(x, h);           % Результат

% Визуализация
figure('Name', 'Lab3_Convolution', 'Color', 'w');
subplot(3,1,1); stem(x); title('Вход x[n]'); ylim([0 1.2]);
subplot(3,1,2); stem(h); title('Фильтр h[n]'); xlim([0 length(x)]);
subplot(3,1,3); stem(y); title('Выход y[n] = x * h');

%% 4. ЭФФЕКТ ЭХО (AUDIO)
fs = 8000;
t = 0:1/fs:0.5;
x_sound = zeros(size(t));
x_sound(800:1600) = 1; % Короткий звук

% Создаем эхо
delay = round(0.1 * fs); % 100 мс
h_echo = zeros(1, delay*2 + 1);
h_echo(1) = 1;         % Прямой
h_echo(delay+1) = 0.6; % Эхо 1
h_echo(end) = 0.3;     % Эхо 2

y_echo = conv(x_sound, h_echo);

% Визуализация
figure('Name', 'Lab3_Echo', 'Color', 'w');
t_out = (0:length(y_echo)-1)/fs;

subplot(2,1,1); plot(t, x_sound); title('Исходный звук');
subplot(2,1,2); plot(t_out, y_echo, 'g'); title('Звук с эхом');

%% 5. ЗАДАНИЕ: ФИЛЬТРАЦИЯ ШУМА
% Задача: Очистить синусоиду от шума фильтром скользящего среднего.

% 1. Генерация
fs = 1000;
t = 0:1/fs:2;
s_pure = sin(2*pi*5*t);
noise = 0.5 * randn(size(t));
x_noisy = s_pure + noise;

% 2. Фильтр (Moving Average)
M = 50;           % Окно усреднения (50 точек)
h_ma = ones(1, M) / M;

% 3. Фильтрация
% 'same' возвращает вектор той же длины, что и вход
y_filtered = conv(x_noisy, h_ma, 'same');

% 4. Визуализация
figure('Name', 'Lab3_Task', 'Color', 'w');
plot(t, x_noisy, 'Color', [0.7 0.7 0.7]); hold on;
plot(t, y_filtered, 'r', 'LineWidth', 2);
plot(t, s_pure, 'b--', 'LineWidth', 1);

title('Подавление шума методом скользящего среднего (MA-50)');
legend('Зашумленный', 'Отфильтрованный', 'Идеал');
xlabel('Время, с');
grid on;

%% КОНЕЦ ЛАБОРАТОРНОЙ РАБОТЫ №3
