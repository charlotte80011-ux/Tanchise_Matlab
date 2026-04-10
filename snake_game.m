function optimized_snake_game()
% ==============================
% Matlab贪吃蛇（Mac 2025b适配+穿墙版）- v1.0
% ==============================

    % 1. 核心变量初始化
    snake = [20,15; 19,15; 18,15];    
    dir = [1,0];                      
    food = [0,0];                     
    score = 0;                        
    level = 1;                        
    speed = 0.12;                     
    game_over = false;                
    game_pause = false;               

    %% 2. 创建游戏界面
    fig = figure('Name','🎮 Matlab贪吃蛇','NumberTitle','off',...
        'Position',[100,100,800,600],'Color',[0.12 0.12 0.15],...
        'CloseRequestFcn',@close_game, 'KeyPressFcn',@key_control);
    movegui(fig,'center');

    ax = axes('Parent',fig,'Position',[0.05,0.15,0.9,0.8],...
        'XLim',[0,40],'YLim',[0,30],'XTick',[],'YTick',[],...
        'Color',[0.08 0.08 0.1],'Box','on','GridAlpha',0.1);
    grid on; hold on;

    txt_score = uicontrol('Style','text','Parent',fig,...
        'String','分数: 0 | 等级: 1',...
        'Position',[300,550,200,30],'ForegroundColor',[0.2 1 0.5],...
        'BackgroundColor',[0.12 0.12 0.15],'FontSize',14,'FontWeight','bold','FontName','Arial');

    txt_tip = uicontrol('Style','text','Parent',fig,...
        'String','方向键控制 | 空格=暂停 | R=重启 | 撞墙穿墙',...
        'Position',[220,30,350,25],'ForegroundColor',[0.8 0.8 0.8],...
        'BackgroundColor',[0.12 0.12 0.15],'FontSize',11,'FontName','Arial');

    snake_body = plot(ax,snake(:,1),snake(:,2),'s','MarkerSize',10,...
        'MarkerFaceColor',[0.2 1 0.5],'MarkerEdgeColor',[0 0.7 0.3],'LineWidth',1);
    
    food_plot = plot(ax,food(1),food(2),'o','MarkerSize',10,...
        'MarkerFaceColor',[1 0.4 0.1],'MarkerEdgeColor',[0.8 0.2 0],'LineWidth',1);

    % 生成第一个食物
    generate_food();

    %% 3. 游戏主循环
    while ishandle(fig)  
        if game_over
            if ishandle(txt_score)
                set(txt_score,'String','❌ 撞到自己！按 R 重启');
            end
            pause(0.1);
            continue;
        end
        
        if game_pause
            pause(0.1);
            continue;
        end
        
        % 蛇移动
        head = snake(1,:) + dir;
        
        % ============
        % 核心：穿墙逻辑
        % ============
        if head(1) > 40
            head(1) = 1;
        elseif head(1) < 1
            head(1) = 40;
        elseif head(2) > 30
            head(2) = 1;
        elseif head(2) < 1
            head(2) = 30;
        end
        
        % 仅移动时，数组大小不变
        snake = [head; snake(1:end-1,:)]; 
        
        % 碰撞检测（撞自己）
        collision = false;
        for i = 2:size(snake,1)
            if snake(i,1)==head(1) && snake(i,2)==head(2)
                collision = true;
                break;
            end
        end
        if collision
            game_over = true;
            beep;
        end
        
        % 吃到食物
        if head(1)==food(1) && head(2)==food(2)
            % 蛇身加长。使用 %#ok<AGROW> 告诉 MATLAB 忽略这里的数组增长警告，
            % 因为在贪吃蛇这种小体量游戏中，动态增长带来的性能损耗微乎其微。
            snake = [head; snake]; %#ok<AGROW>  
            score = score + 10;
            
            if mod(score,50)==0 && level<8
                level = level + 1;
                speed = max(0.04, speed-0.015);
            end
            generate_food();  
        end
        
        % 更新画面
        if ishandle(snake_body)
            set(snake_body,'XData',snake(:,1),'YData',snake(:,2));
        end
        if ishandle(food_plot)
            set(food_plot,'XData',food(1),'YData',food(2));
        end
        if ishandle(txt_score)
            set(txt_score,'String',sprintf('分数: %d | 等级: %d',score,level));
        end
        
        drawnow;  
        pause(speed);
    end

    %% ================= 嵌套子函数区域 ================= %%
    % 嵌套函数可以直接访问和修改主函数(optimized_snake_game)中的变量
    
    function key_control(~,event)
        if ~ishandle(fig), return; end
        key = event.Key;
        
        if strcmp(key,'space')
            game_pause = ~game_pause;
            return;
        end
        
        if strcmpi(key,'r') % 忽略大小写的比较
            reset_game();
            return;
        end
        
        if game_pause || game_over, return; end
        
        switch key
            case 'uparrow'
                if dir(2)~=-1, dir = [0,1]; end
            case 'downarrow'
                if dir(2)~=1, dir = [0,-1]; end
            case 'leftarrow'
                if dir(1)~=1, dir = [-1,0]; end
            case 'rightarrow'
                if dir(1)~=-1, dir = [1,0]; end
        end
    end

    function generate_food()
        while true
            fx = randi([1,40]); % 修正：X轴范围应为1-40
            fy = randi([1,30]); % 修正：Y轴范围应为1-30
            
            % 判断是否生成在蛇身上
            on_snake = any(snake(:,1) == fx & snake(:,2) == fy);
            
            if ~on_snake
                food = [fx, fy];
                break;
            end
        end
    end

    function reset_game()
        snake = [20,15; 19,15; 18,15];
        dir = [1,0];
        score = 0;
        level = 1;
        speed = 0.12;
        game_over = false;
        game_pause = false;
        generate_food();
        
        if ishandle(txt_score)
            set(txt_score,'String','分数: 0 | 等级: 1');
        end
    end

    function close_game(~,~)
        if ishandle(fig)
            delete(fig);
        end
    end
end