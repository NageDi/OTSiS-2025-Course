%% lab1_8_generate_data.m
%% Генерация тестового сигнала датчика для Раздела Г лабораторной 1.8
%% Запустить ОДИН РАЗ перед выполнением lab1_8_template.m

rng(2024);   % Фиксированный seed для воспроизводимости

fs_s    = 1000;         % Частота дискретизации датчика, Гц
T_s     = 10;           % Длительность записи, с
t_s     = (0:1/fs_s:T_s-1/fs_s)';

% --- Полезный сигнал (медленный тренд температуры) ---
signal_clean = 25 + 3*sin(2*pi*0.2*t_s) + 1.5*sin(2*pi*0.5*t_s);

% --- Помехи (электромагнитные наводки от электрооборудования) ---
noise_50hz  = 2.0 * sin(2*pi*50*t_s + rand*2*pi);    % 50 Гц (сеть)
noise_150hz = 0.8 * sin(2*pi*150*t_s + rand*2*pi);   % 150 Гц (3-я гармоника)
noise_rand  = 0.3 * randn(size(t_s));                  % Белый шум

% --- Итоговый сигнал ---
sensor_signal = signal_clean + noise_50hz + noise_150hz + noise_rand;

% Сохранить в mat-файл
save('sensor_data.mat', 'sensor_signal', 'signal_clean', 'fs_s', 't_s');

% Метаданные для преподавателя (не раскрывать студентам!)
fprintf('=== Данные сгенерированы ===\n');
fprintf('Полезный сигнал: 0.2 Гц + 0.5 Гц\n');
fprintf('Помехи: 50 Гц (A=2), 150 Гц (A=0.8)\n');
fprintf('Белый шум: σ = 0.3\n');
fprintf('Файл сохранён: sensor_data.mat\n');

% Предварительный график
figure;
subplot(2,1,1);
plot(t_s, sensor_signal, 'b', 'LineWidth',0.5);
hold on; plot(t_s, signal_clean, 'r', 'LineWidth',1.5);
legend('Сигнал датчика (с помехами)', 'Чистый сигнал');
xlabel('Время, с'); ylabel('Температура, °C');
title('Сигнал датчика температуры АСУТП');
grid on;

subplot(2,1,2);
N_g = length(sensor_signal);
f_g = (0:N_g-1)*fs_s/N_g;
S_g = abs(fft(sensor_signal))/N_g*2;
plot(f_g(1:N_g/2), S_g(1:N_g/2));
xlabel('Частота, Гц'); ylabel('Амплитуда');
title('Спектр сигнала датчика — задача студента: найти и отфильтровать помехи');
xlim([0 200]); grid on;
