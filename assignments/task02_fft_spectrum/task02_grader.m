%% Автопроверка — Задание 2: Спектр через FFT
fprintf('\n╔══════════════════════════════════════════════════╗\n');
fprintf('║    ПРОВЕРКА — ЗАДАНИЕ 2: Спектральный анализ     ║\n');
fprintf('╚══════════════════════════════════════════════════╝\n\n');
score=0; r={};

fs_r=2000; T_r=1; N_r=fs_r*T_r; f0_r=50;
t_r=0:1/fs_r:T_r-1/fs_r;
x_r=3*sin(2*pi*f0_r*t_r)+1.5*sin(2*pi*2*f0_r*t_r)+0.5*sin(2*pi*5*f0_r*t_r);
X_r = fft(x_r,N_r);
f_r = (0:N_r/2-1)*fs_r/N_r;
X_mag_ref = abs(X_r(1:N_r/2))*2/N_r;

%% X_mag
try
    assert(exist('X_mag','var')==1,'X_mag не найдена');
    assert(length(X_mag)==N_r/2, sprintf('Длина X_mag=%d, ожидалось %d',length(X_mag),N_r/2));
    rmse_xm=sqrt(mean((X_mag(:)'-X_mag_ref).^2));
    assert(rmse_xm<0.05, sprintf('X_mag отличается: RMSE=%.4f',rmse_xm));
    score=score+3; r{end+1}=sprintf('✅ [+3] X_mag: спектр верен (RMSE=%.5f)',rmse_xm);
catch ME; r{end+1}=sprintf('❌ [+0] X_mag: %s',ME.message); end

%% f_fundamental
try
    assert(exist('f_fundamental','var')==1,'f_fundamental не найдена');
    assert(abs(f_fundamental-f0_r)<2, sprintf('f_fundamental=%.1f, эталон=%d',f_fundamental,f0_r));
    score=score+2; r{end+1}=sprintf('✅ [+2] f_fundamental = %.1f Гц', f_fundamental);
catch ME; r{end+1}=sprintf('❌ [+0] f_fundamental: %s',ME.message); end

%% A_h1, A_h2, A_h3
for vi = {{'A_h1',3.0},{'A_h2',1.5},{'A_h3',0.5}}
    name=vi{1}{1}; expected=vi{1}{2};
    try
        assert(exist(name,'var')==1, sprintf('%s не найдена',name));
        val=eval(name);
        assert(abs(val-expected)<0.05, sprintf('%s=%.4f, эталон=%.1f',name,val,expected));
        score=score+1; r{end+1}=sprintf('✅ [+1] %s = %.4f',name,val);
    catch ME; r{end+1}=sprintf('❌ [+0] %s: %s',name,ME.message); end
end

fprintf('────────────────────────────────────────────────────\n');
for i=1:length(r); fprintf('  %s\n',r{i}); end
fprintf('\n  БАЛЛ: %d/10 (5 х проверок, макс. 10)\n',score);  % score 3+2+1+1+1=8 max, scale /8*10
fprintf('════════════════════════════════════════════════════\n\n');
