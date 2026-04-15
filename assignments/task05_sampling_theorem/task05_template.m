%% ЗАДАНИЕ 5: Дискретизация. Теорема Котельникова. Алиасинг.
%% ФИО: ___________________ Группа: ___________

clear; close all; clc;

%% --- Параметры аналогового сигнала (не изменять!) ---
fmax     = 100;         % Максимальная частота сигнала, Гц
fs_cont  = 100000;      % «Аналоговый» сигнал (очень высокая fs)
T        = 0.1;         % Длительность, с
t_cont   = 0:1/fs_cont:T-1/fs_cont;

% Аналоговый сигнал: сумма двух гармоник
x_analog = sin(2*pi*80*t_cont) + 0.5*sin(2*pi*100*t_cont);

%% --- Три частоты дискретизации ---
% fs1 — частота Найквиста: выполнена теорема
% fs2 — НАРУШЕНИЕ теоремы (в 2 раза меньше): алиасинг!
% fs3 — перекрытие (в 4 раза выше fmax)
fs1 = 250;      % > 2*fmax = 200 Гц — OK
fs2 = 120;      % < 2*fmax = 200 Гц — АЛИАСИНГ!
fs3 = 500;      % >> 2*fmax — перекрытие

%% --- ШАГ 1: Дискретизация при fs1 (250 Гц) ---
% TODO: Выбрать отсчёты через step1 = round(fs_cont/fs1)
step1     = round(fs_cont/fs1);
t_d1      = t_cont(1:step1:end);
x_d1      = x_analog(1:step1:end);
% TODO: Восстановить через sinc-интерполяцию (interp1 'spline')
x_r1      = interp1(t_d1, x_d1, t_cont, 'spline', 'extrap');

%% --- ШАГ 2: Дискретизация при fs2 (120 Гц) — алиасинг ---
step2     = round(fs_cont/fs2);
t_d2      = t_cont(1:step2:end);
x_d2      = x_analog(1:step2:end);
% TODO: Восстановить
x_r2      = interp1(t_d2, x_d2, t_cont, 'spline', 'extrap');

%% --- ШАГ 3: Дискретизация при fs3 (500 Гц) ---
step3     = round(fs_cont/fs3);
t_d3      = t_cont(1:step3:end);
x_d3      = x_analog(1:step3:end);
x_r3      = interp1(t_d3, x_d3, t_cont, 'spline', 'extrap');

%% --- ШАГ 4: SNR (качество восстановления) ---
P_sig    = mean(x_analog.^2);
% TODO: Вычислить SNR для каждой частоты дискретизации
snr_fs1  = 10*log10(P_sig / mean((x_r1 - x_analog).^2));   % OK
snr_fs2  = ???;    % 10*log10(P_sig / mean((x_r2 - x_analog).^2))  — должен быть мал
snr_fs3  = ???;    % аналогично

%% --- ШАГ 5: Алиасинг — частота-двойник ---
% При fs2=120 Гц и исходной частоте 100 Гц появляется alias-частота:
% f_alias = |f - n*fs2| — ближайшая к 0
f_alias_100 = mod(100, fs2);            % Alias для 100 Гц
if f_alias_100 > fs2/2; f_alias_100 = fs2 - f_alias_100; end
f_alias = f_alias_100;   % Сохранить для проверки!

%% --- Графики ---
figure('Name', 'Задание 5: Дискретизация и алиасинг', 'Position',[100 50 1000 700]);

% fs1 = 250 Гц
subplot(3,2,1);
plot(t_cont, x_analog,'k','LineWidth',0.5); hold on;
stem(t_d1, x_d1,'b','filled','MarkerSize',4);
title(sprintf('Дискретизация fs=%d Гц (OK)', fs1)); grid on;
xlabel('Время, с');

subplot(3,2,2);
plot(t_cont, x_analog,'k','LineWidth',0.5); hold on;
plot(t_cont, x_r1,'b','LineWidth',1.5);
title(sprintf('Восстановление fs=%d Гц | SNR=%.1f дБ', fs1, snr_fs1)); grid on;
xlabel('Время, с');

% fs2 = 120 Гц — Алиасинг!
subplot(3,2,3);
plot(t_cont, x_analog,'k','LineWidth',0.5); hold on;
stem(t_d2, x_d2,'r','filled','MarkerSize',5);
title(sprintf('АЛИАСИНГ! fs=%d Гц < 2·fmax=%d Гц', fs2, 2*fmax));
grid on; xlabel('Время, с');

subplot(3,2,4);
plot(t_cont, x_analog,'k','LineWidth',0.5); hold on;
plot(t_cont, x_r2,'r','LineWidth',1.5);
title(sprintf('Восстановление fs=%d Гц | SNR=%.1f дБ | alias=%.0f Гц', ...
    fs2, snr_fs2, f_alias)); grid on;
xlabel('Время, с');

% fs3 = 500 Гц
subplot(3,2,5);
plot(t_cont, x_analog,'k','LineWidth',0.5); hold on;
stem(t_d3, x_d3,'g','filled','MarkerSize',3);
title(sprintf('Перекрытие fs=%d Гц', fs3)); grid on;
xlabel('Время, с');

subplot(3,2,6);
plot(t_cont, x_analog,'k','LineWidth',0.5); hold on;
plot(t_cont, x_r3,'g','LineWidth',1.5);
title(sprintf('Восстановление fs=%d Гц | SNR=%.1f дБ', fs3, snr_fs3)); grid on;
xlabel('Время, с');

sgtitle('Теорема Котельникова: влияние частоты дискретизации');

fprintf('\n=== РЕЗУЛЬТАТЫ ===\n');
fprintf('fs=%d Гц (OK):       SNR = %.1f дБ\n', fs1, snr_fs1);
fprintf('fs=%d Гц (АЛИАСИНГ): SNR = %.1f дБ | alias-частота = %.0f Гц\n', fs2, snr_fs2, f_alias);
fprintf('fs=%d Гц (перекрыт): SNR = %.1f дБ\n', fs3, snr_fs3);
fprintf('\nЗапустите task05_grader.m для проверки.\n');
