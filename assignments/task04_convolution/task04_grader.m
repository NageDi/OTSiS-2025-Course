%% Автопроверка — Задание 4: Свёртка
fprintf('\n╔════════════════════════════════════════════════╗\n');
fprintf('║    ПРОВЕРКА — ЗАДАНИЕ 4: Свёртка              ║\n');
fprintf('╚════════════════════════════════════════════════╝\n\n');
score=0; r={};

fs_r=1000; T_r=0.1; t_r=0:1/fs_r:T_r-1/fs_r;
x1_r=sin(2*pi*20*t_r).*(t_r<0.05);
x2_r=exp(-50*t_r).*double(t_r>=0);
y_ref=conv(x1_r,x2_r)/fs_r;

%% y_conv
try
    assert(exist('y_conv','var')==1,'y_conv не найдена');
    assert(length(y_conv)==length(y_ref), ...
        sprintf('Длина y_conv=%d, ожидалось %d',length(y_conv),length(y_ref)));
    rmse_yc=sqrt(mean((y_conv(:)'-y_ref).^2));
    assert(rmse_yc<1e-10,'y_conv не совпадает с эталоном');
    score=score+4; r{end+1}=sprintf('✅ [+4] y_conv через conv(): RMSE=%.2e',rmse_yc);
catch ME; r{end+1}=sprintf('❌ [+0] y_conv: %s',ME.message); end

%% y_manual
try
    assert(exist('y_manual','var')==1,'y_manual не найдена');
    rmse_ym=sqrt(mean((y_manual(:)'-y_ref).^2));
    assert(rmse_ym<1e-9,'y_manual не совпадает');
    score=score+4; r{end+1}=sprintf('✅ [+4] y_manual (вручную): RMSE=%.2e',rmse_ym);
catch ME; r{end+1}=sprintf('❌ [+0] y_manual: %s',ME.message); end

%% Совпадение conv и manual
try
    assert(exist('y_conv','var')==1 && exist('y_manual','var')==1);
    rmse_cmp=sqrt(mean((y_conv(:)'-y_manual(:)').^2));
    assert(rmse_cmp<1e-9,'conv() и y_manual расходятся');
    score=score+2; r{end+1}=sprintf('✅ [+2] conv() == вручную: расхождение=%.2e',rmse_cmp);
catch ME; r{end+1}=sprintf('❌ [+0] Совпадение: %s',ME.message); end

fprintf('────────────────────────────────────────────────────\n');
for i=1:length(r); fprintf('  %s\n',r{i}); end
fprintf('\n  БАЛЛ: %d/10\n',score);
if score>=9; g='ОТЛИЧНО'; elseif score>=7; g='ХОРОШО'; elseif score>=5; g='УДОВЛ.'; else; g='НЕУДОВЛ.'; end
fprintf('  ОЦЕНКА: %s\n════════════════════════════════════════════════════\n\n',g);
