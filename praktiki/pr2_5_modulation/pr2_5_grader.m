%% Автоматический проверщик — Пр 2.5
%% АМ и ЧМ модуляция

fprintf('\n╔══════════════════════════════════════════════════════════╗\n');
fprintf('║        ПРОВЕРКА — ПР 2.5: АМ и ЧМ модуляция             ║\n');
fprintf('╚══════════════════════════════════════════════════════════╝\n\n');

score = 0; results = {};

fc_r=1000; fm_r=50; m_r=0.6; A_c_r=1; fs_r=20000; T_r=0.1;
t_r=0:1/fs_r:T_r-1/fs_r; N_r=length(t_r);

%% Проверка 1: x_am
try
    assert(exist('x_am','var')==1,'x_am не найдена');
    x_am_ref = A_c_r*(1 + m_r*cos(2*pi*fm_r*t_r)).*cos(2*pi*fc_r*t_r);
    rmse_am  = sqrt(mean((x_am(:)' - x_am_ref).^2));
    assert(rmse_am < 0.01, sprintf('x_am RMSE=%.5f',rmse_am));
    score=score+2; results{end+1}=sprintf('✅ [+2] x_am: корректен (RMSE=%.5f)',rmse_am);
catch ME; results{end+1}=sprintf('❌ [+0] x_am: %s',ME.message); end

%% Проверка 2: envelope_am
try
    assert(exist('envelope_am','var')==1,'envelope_am не найдена');
    env_ref = abs(hilbert(A_c_r*(1+m_r*cos(2*pi*fm_r*t_r)).*cos(2*pi*fc_r*t_r)));
    rmse_env = sqrt(mean((envelope_am(:)' - env_ref).^2));
    assert(rmse_env < 0.05, sprintf('envelope_am RMSE=%.4f',rmse_env));
    score=score+1; results{end+1}=sprintf('✅ [+1] envelope_am: корректна');
catch ME; results{end+1}=sprintf('❌ [+0] envelope_am: %s',ME.message); end

%% Проверка 3: eta_am
try
    assert(exist('eta_am','var')==1,'eta_am не найдена');
    P_c_r = A_c_r^2/2; P_s_r = 2*(m_r*A_c_r/2)^2/2;
    eta_ref = P_s_r/(P_c_r+P_s_r);
    assert(abs(eta_am-eta_ref)<0.005, sprintf('eta_am=%.4f, эталон=%.4f',eta_am,eta_ref));
    score=score+2; results{end+1}=sprintf('✅ [+2] eta_am = %.4f (%.2f%%)',eta_am,eta_am*100);
catch ME; results{end+1}=sprintf('❌ [+0] eta_am: %s',ME.message); end

%% Проверка 4: x_fm
try
    assert(exist('x_fm','var')==1,'x_fm не найдена');
    f_dev_r=200; mf_r=f_dev_r/fm_r;
    x_fm_ref = A_c_r*cos(2*pi*fc_r*t_r + mf_r*sin(2*pi*fm_r*t_r));
    rmse_fm  = sqrt(mean((x_fm(:)' - x_fm_ref).^2));
    assert(rmse_fm < 0.05, sprintf('x_fm RMSE=%.4f',rmse_fm));
    score=score+2; results{end+1}=sprintf('✅ [+2] x_fm: корректен');
catch ME; results{end+1}=sprintf('❌ [+0] x_fm: %s',ME.message); end

%% Проверка 5: BW_carson
try
    assert(exist('BW_carson','var')==1,'BW_carson не найдена');
    BW_ref = 2*(200+50);
    assert(abs(BW_carson-BW_ref)<1, sprintf('BW_carson=%.1f, эталон=%.1f',BW_carson,BW_ref));
    score=score+2; results{end+1}=sprintf('✅ [+2] BW_carson = %.1f Гц',BW_carson);
catch ME; results{end+1}=sprintf('❌ [+0] BW_carson: %s',ME.message); end

%% Проверка 6: f_inst
try
    assert(exist('f_inst','var')==1,'f_inst не найдена');
    f_inst_ref = fc_r + 200*cos(2*pi*fm_r*t_r);
    rmse_fi = sqrt(mean((f_inst(:)'-f_inst_ref).^2));
    assert(rmse_fi<5,sprintf('f_inst RMSE=%.2f',rmse_fi));
    score=score+1; results{end+1}='✅ [+1] f_inst: мгновенная частота верна';
catch ME; results{end+1}=sprintf('❌ [+0] f_inst: %s',ME.message); end

%% Итог
fprintf('────────────────────────────────────────────────────────────\n');
for i=1:length(results); fprintf('  %s\n',results{i}); end
fprintf('\n  ИТОГОВЫЙ БАЛЛ: %d / 10\n', score);
if score>=9; g='ОТЛИЧНО'; elseif score>=7; g='ХОРОШО'; elseif score>=5; g='УДОВЛ.'; else; g='НЕУДОВЛ.'; end
fprintf('  ОЦЕНКА: %s\n════════════════════════════════════════════════════════════\n\n',g);
