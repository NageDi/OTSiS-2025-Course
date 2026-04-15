%% Автопроверка — Задание 3: Ряд Фурье
fprintf('\n╔══════════════════════════════════════════════════╗\n');
fprintf('║    ПРОВЕРКА — ЗАДАНИЕ 3: Ряд Фурье              ║\n');
fprintf('╚══════════════════════════════════════════════════╝\n\n');
score=0; r={};

T_r=1; A_r=1; fs_r=5000;
t_r=0:1/fs_r:2*T_r-1/fs_r;
x_ideal_r = A_r*square(2*pi/T_r*t_r);
N_list_r = [1,5,15,51,201];

% Эталонный fourier_coeffs
fc_ref = zeros(1,5);
for i=1:5
    N_h = N_list_r(i); xs=zeros(size(t_r));
    for k=1:2:N_h; xs=xs+(1/k)*sin(2*pi*k*t_r/T_r); end
    x_N_r=(4*A_r/pi)*xs;
    fc_ref(i)=sqrt(mean((x_N_r-x_ideal_r).^2));
end

%% fourier_coeffs
try
    assert(exist('fourier_coeffs','var')==1,'fourier_coeffs не найдена');
    assert(length(fourier_coeffs)==5,'Длина должна быть 5');
    assert(max(abs(fourier_coeffs(:)'-fc_ref))<0.01,...
        'fourier_coeffs не совпадает с эталоном');
    % Должна убывать
    assert(fourier_coeffs(end)<fourier_coeffs(1),'RMSE должна убывать с ростом N');
    score=score+5; r{end+1}=sprintf('✅ [+5] fourier_coeffs: 5 значений, убывают, совпадают с эталоном');
catch ME; r{end+1}=sprintf('❌ [+0] fourier_coeffs: %s',ME.message); end

%% x_N_51
try
    assert(exist('x_N_51','var')==1,'x_N_51 не найдена');
    xs51=zeros(size(t_r));
    for k=1:2:51; xs51=xs51+(1/k)*sin(2*pi*k*t_r/T_r); end
    x_ref51=(4*A_r/pi)*xs51;
    rmse51=sqrt(mean((x_N_51(:)'-x_ref51).^2));
    assert(rmse51<1e-9,'x_N_51 не совпадает с эталоном');
    score=score+5; r{end+1}=sprintf('✅ [+5] x_N_51: N=51 синтез верен (RMSE=%.2e)',rmse51);
catch ME; r{end+1}=sprintf('❌ [+0] x_N_51: %s',ME.message); end

fprintf('────────────────────────────────────────────────────\n');
for i=1:length(r); fprintf('  %s\n',r{i}); end
fprintf('\n  БАЛЛ: %d/10\n',score);
if score>=9; g='ОТЛИЧНО'; elseif score>=7; g='ХОРОШО'; elseif score>=5; g='УДОВЛ.'; else; g='НЕУДОВЛ.'; end
fprintf('  ОЦЕНКА: %s\n════════════════════════════════════════════════════\n\n',g);
