%% Автопроверка — Задание 7: Энергия и мощность
fprintf('\n╔══════════════════════════════════════════════════════╗\n');
fprintf('║    ПРОВЕРКА — ЗАДАНИЕ 7: Энергия и мощность         ║\n');
fprintf('╚══════════════════════════════════════════════════════╝\n\n');
score=0; r={};

fs_r=2000; T_r=2; N_r=fs_r*T_r;
t_r=0:1/fs_r:T_r-1/fs_r;
x_e_r=exp(-3*t_r).*sin(2*pi*50*t_r);
x_p_r=2*sin(2*pi*30*t_r)+sin(2*pi*90*t_r);

E_ref = sum(x_e_r.^2)/fs_r;
P_ref = sum(x_p_r.^2)/(fs_r*T_r);

%% E_energy
try
    assert(exist('E_energy','var')==1,'E_energy не найдена');
    assert(abs(E_energy-E_ref)/E_ref < 0.01, ...
        sprintf('E_energy=%.5f, эталон=%.5f',E_energy,E_ref));
    score=score+4; r{end+1}=sprintf('✅ [+4] E_energy = %.5f Дж (верно)',E_energy);
catch ME; r{end+1}=sprintf('❌ [+0] E_energy: %s',ME.message); end

%% P_power
try
    assert(exist('P_power','var')==1,'P_power не найдена');
    assert(abs(P_power-P_ref)/P_ref < 0.01, ...
        sprintf('P_power=%.5f, эталон=%.5f',P_power,P_ref));
    score=score+3; r{end+1}=sprintf('✅ [+3] P_power = %.5f Вт',P_power);
catch ME; r{end+1}=sprintf('❌ [+0] P_power: %s',ME.message); end

%% ESD (Parseval)
try
    assert(exist('ESD','var')==1,'ESD не найдена');
    assert(length(ESD)==N_r,'Длина ESD должна быть N');
    % Энергия через ESD должна ≈ E_energy
    E_from_ESD = sum(ESD)/fs_r;
    assert(abs(E_from_ESD-E_ref)/E_ref < 0.05, ...
        sprintf('Теорема Парсеваля: E_ESD=%.5f, E_num=%.5f',E_from_ESD,E_ref));
    score=score+3; r{end+1}=sprintf('✅ [+3] ESD: теорема Парсеваля ≈ выполняется (E=%.5f)',E_from_ESD);
catch ME; r{end+1}=sprintf('❌ [+0] ESD: %s',ME.message); end

fprintf('────────────────────────────────────────────────────\n');
for i=1:length(r); fprintf('  %s\n',r{i}); end
fprintf('\n  БАЛЛ: %d/10\n',score);
if score>=9; g='ОТЛИЧНО'; elseif score>=7; g='ХОРОШО'; elseif score>=5; g='УДОВЛ.'; else; g='НЕУДОВЛ.'; end
fprintf('  ОЦЕНКА: %s\n════════════════════════════════════════════════════\n\n',g);
