% ==============================================
% 图像匹配程序主函数
% 创建时间：2026/5/9
% 功能：导入参考图像和待匹配图像，进行图像匹配
% ==============================================

% ========== 初始化环境 ==========
% 清理工作区
clc;clear;close all; warning('off')


% 添加Create_Image_Space文件夹到MATLAB路径，使主函数可以调用其中的函数
addpath('MSRCR')
addpath('Create_Image_Space');

addpath('KeypointDetection');
addpath('FeatureDescriptors');
addpath('FeatureMatching');
addpath('MyMatch');







% 交互式选择图像及文件
[file1, path1] = uigetfile({'*.jpg;*.png;*.bmp;*.tif','Image Files'}, '选择第一张图像');
  if isequal(file1,0)
      error('未选择图像');
  end
      str1 = fullfile(path1, file1);

[file2, path2] = uigetfile({'*.jpg;*.png;*.bmp;*.tif','Image Files'}, '选择第二张图像');
  if isequal(file2,0)
      error('未选择图像');
  end
    str2 = fullfile(path2, file2);

% [gtfile, gtpath] = uigetfile('*.txt', '选择真值文件');
% if isequal(gtfile,0)
%      error('未选择真值文件');
%  end
%  gtstr = fullfile(gtpath, gtfile);
%   gt=load(gtstr);


%%  
    im1 = uint8(imread(str1));
    im2 = uint8(imread(str2));

    % 显示原始图像im1和im2
    figure('Name', '原始图像', 'NumberTitle', 'off');
    subplot(1,2,1);
    imshow(im1);
    title('图像1 (im1)');
    subplot(1,2,2);
    imshow(im2);
    title('图像2 (im2)');
    

    
    %im1 = uint8(imread(str1));
    %im2 = uint8(imread(str2));
    % im1 = uint8(imread('pair1-1.jpg'));
    % im2 = uint8(imread('pair1-2.jpg'));
    


    [~,~,num1]=size(im1);
    [~,~,num2]=size(im2);
    if(num1==3)
        image_11=adapthisteq(rgb2gray(im1));
    else
        image_11=adapthisteq(im1);
    end
    if(num2==3)
        image_22=adapthisteq(rgb2gray(im2));
    else
        image_22=adapthisteq(im2);
    end

    image_11 = double(image_11);
    image_22 = double(image_22);
    
    % % 显示处理后的图像im1和im2
    % figure('Name', '处理后的图像', 'NumberTitle', 'off');
    % subplot(1,2,1);
    % imshow(uint8(image_11),[]);
    % title('图像1 (im1)');
    % subplot(1,2,2);
    % imshow(uint8(image_22),[]);
    % title('图像2 (im2)');
    

   


% ========== 后续匹配流程（预留）==========
% 这里可以添加特征提取、描述子生成、特征匹配等后续步骤


num_layers=4;
scale_ratio=2^(1/3);
sigma_initial=1.6;
change_form='Similarity';  % 变换模型类型：'Similarity'(相似变换) / 'Affine'(仿射变换)

% 共现滤波初始窗口大小（可选[3,5,10]）：窗口越大滤波越平滑，特征点越少；越小保留细节越多但易引入噪声
sigma_s=5;  


Logical_Threshold=0.75;
KeyPoint_Threshold=8;
AGGREGATE_RESPONSE_THRESHOLD=0.45 ;  % 聚合特征响应阈值;
LOG_POLAR_WIDTH=12;
LOG_POLAR__HIST_BINS=8;



[scale_space_1] = Create_Image_Space(image_11, num_layers, scale_ratio, sigma_initial,sigma_s,Logical_Threshold); 
[scale_space_2] = Create_Image_Space(image_22, num_layers, scale_ratio, sigma_initial,sigma_s,Logical_Threshold);  

[keypoints_1, gradient_1, angle_1, ~]=FindKeypointDetection(scale_space_1,scale_ratio,sigma_initial,KeyPoint_Threshold,AGGREGATE_RESPONSE_THRESHOLD);
[keypoints_2, gradient_2, angle_2, ~]=FindKeypointDetection(scale_space_2,scale_ratio,sigma_initial,KeyPoint_Threshold,AGGREGATE_RESPONSE_THRESHOLD);

[descriptors_1,locs_1]=MyGLOH_descriptors(gradient_1,angle_1,keypoints_1,LOG_POLAR_WIDTH,LOG_POLAR__HIST_BINS);
[descriptors_2,locs_2]=MyGLOH_descriptors(gradient_2,angle_2,keypoints_2,LOG_POLAR_WIDTH,LOG_POLAR__HIST_BINS);


[solution,rmse,cor2,cor1]=match(descriptors_2,locs_2,descriptors_1,locs_1,change_form);

H=inv(solution);

%[solution,rmse,cor1,cor2]=match(descriptors_1,locs_1,descriptors_2,locs_2,change_form);
%H=solution;




    matchedPoints1 = cor1(:,1:2);
    matchedPoints2 = cor2(:,1:2);
    figure;
    button=showMatchedFeatures(image_11, image_22, matchedPoints1, matchedPoints2, 'montage');
    fprintf('  完成 | 内点数量：%d | RMSE：%.4f\n', size(matchedPoints1,1), rmse);
   % 
   % H=[gt;0 0 1];
    Y_=H*[matchedPoints1';ones(1,size(matchedPoints1,1))];
    Y_(1,:)=Y_(1,:)./Y_(3,:);
    Y_(2,:)=Y_(2,:)./Y_(3,:);
    E=sqrt(sum((Y_(1:2,:)-matchedPoints2').^2));
    inliersIndex=E<3;
    cleanedPoints1 = matchedPoints1(inliersIndex, :);
    cleanedPoints2 = matchedPoints2(inliersIndex, :);
    [cleanedPoints2,IA] = unique(cleanedPoints2,'rows');
    cleanedPoints1 = cleanedPoints1(IA,:);
    cleanedPoints=[cleanedPoints1 cleanedPoints2];
    cleanedPoints = double(cleanedPoints);
    Y_=H*[cleanedPoints(:,1:2)';ones(1,size(cleanedPoints,1))];
    Y_(1,:)=Y_(1,:)./Y_(3,:);
    Y_(2,:)=Y_(2,:)./Y_(3,:);
    E=sqrt(sum((Y_(1:2,:)-cleanedPoints(:,3:4)').^2));
    if length(E)<10
        rmse = 20;
    else
        rmse = sqrt(sum(E.^2)/size(E,2));
    end
    length(E)

% ========== 显示尺度空间 ==========
disp('正在显示尺度空间...');
% for layer = 1:num_layers
%     % 显示参考图像（单独窗口）
%     figure('Name', ['参考图像 - 第', num2str(layer), '层']);
%     imshow(uint8(scale_space_1{layer}), []);
%     title(['参考图像 - 第', num2str(layer), '层']);
%     colormap(gray);
% 
%     % 显示匹配图像（单独窗口）
%     figure('Name', ['匹配图像 - 第', num2str(layer), '层']);
%     imshow(uint8(scale_space_2{layer}), []);
%     title(['匹配图像 - 第', num2str(layer), '层']);
%     colormap(gray);
% end
% disp('尺度空间显示完成！');



figure('Name', '特征点匹配连线', 'NumberTitle', 'off');
showMatchedFeatures(im1, im2, cleanedPoints1, cleanedPoints2, 'montage');
title('匹配点连线');

allpoints = size(matchedPoints1, 1);
CM = size(cleanedPoints1, 1);
CMR = (CM / allpoints) * 100;
fprintf('初始匹配点数: %d\n', allpoints);
fprintf('正确匹配点数 (CM): %d\n', CM);
fprintf('正确匹配率 (CMR): %.2f%%\n', CMR);
fprintf('rmse: %d\n', rmse);
%save RES_cofsm.mat RES


%% ============ 添加图像变换部分 ============
% 设置变换参数
trans_form = 'similarity'; % 变换类型：'similarity', 'affine', 'projective', 'polynomial-2'
out_form = 'union';        % 输出范围：'reference', 'union', 'inter', 'geo'
chg_scale = 1;             % 是否改变尺度
show_flag = 1;             % 是否显示变换结果
overlap_flag = 1;          % 是否生成重叠图像
mosaic_flag = 1;           % 是否生成拼接图像


% 调用图像变换函数
fprintf('开始图像变换...\n');
tic;
[I1_r, I2_r, I1_rs, I2_rs, I3, I4, t_form, ~] = Transformation(im1, im2, cleanedPoints1, cleanedPoints2, trans_form, out_form, chg_scale, show_flag, overlap_flag, mosaic_flag);
t_trans = toc; 
fprintf(['已完成图像变换，用时 ',num2str(t_trans),'s\n']);
fprintf(['Done image transformation，time: ',num2str(t_trans),'s\n\n']);

% 显示变换结果
if show_flag
    if overlap_flag && ~isempty(I3)
        figure('Name', '重叠图像', 'NumberTitle', 'off');
        imshow(I3); title('Overlap Form'); drawnow
    end
    if mosaic_flag && ~isempty(I4)
        figure('Name', '拼接图像', 'NumberTitle', 'off');
        imshow(I4); title('Mosaic Form'); drawnow
    end
end
% ============ 图像变换部分结束 ============

fig_features1 = figure('Name', '图像1特征点', 'NumberTitle', 'off', 'Visible', 'on');
imshow(im1); hold on;
plot(keypoints_1(:,1), keypoints_1(:,2), 'ro', 'MarkerSize', 3, 'LineWidth', 1);
title(['图像1特征点 (' num2str(size(keypoints_1,1)) ' 个)']);
hold off;




% tempPoint1=keypoints_1(:,1:2);
% tempPoint2=keypoints_2(:,1:2);
% 
% % 创建新窗口显示特征点
% figure('Name', '特征点显示');
% 
% % 显示参考图像的特征点
% subplot(1,2,1);
% imshow(uint8(image_11), []);
% hold on;
% if ~isempty(tempPoint1)
%     plot(tempPoint1(:,1), tempPoint1(:,2), 'r.', 'MarkerSize', 5);
% end
% title(['参考图像特征点 (', num2str(size(tempPoint1,1)), '个点)']);
% hold off;
% 
% % 显示待配准图像的特征点
% subplot(1,2,2);
% imshow(uint8(image_22), []);
% hold on;
% if ~isempty(tempPoint2)
%     plot(tempPoint2(:,1), tempPoint2(:,2), 'r.', 'MarkerSize', 5);
% end
% title(['待配准图像特征点 (', num2str(size(tempPoint2,1)), '个点)']);
% hold off;
