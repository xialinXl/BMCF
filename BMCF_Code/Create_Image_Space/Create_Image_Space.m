function scale_space = Create_Image_Space_3(gray_image, num_layers, scale_ratio, sigma_initial, sigma_s,Logical_Threshold)
    if size(gray_image, 3) ~= 1
        error('输入图像必须为单通道灰度图像');
    end
    if num_layers <= 0 || num_layers ~= round(num_layers)
        error('尺度空间层数必须为正整数');
    end
    if scale_ratio <= 0
        error('尺度比例因子必须为正数');
    end
    if sigma_initial <= 0
        error('初始高斯滤波标准差必须为正数');
    end
    [M, N] = size(gray_image);
    scale_space = cell(1, num_layers);
    E_space = cell(1, num_layers);
    windows_size=2*round(2*sigma_initial)+1;
    W=fspecial('gaussian',[windows_size,windows_size],sigma_initial);
    im=imfilter(gray_image,W,'replicate');
    scale_space{1}=im;
    sigma=zeros(1,num_layers);
    for i=1:1:num_layers
        sigma(i)=sigma_initial*scale_ratio^(i-1);    
    end
    for i = 2:num_layers
        prev_im = scale_space{i-1};
        E_space{i} = GetThresholdImage(prev_im, Logical_Threshold);
        PatternID_Img = GetPatternID(E_space{i});
        sigma_OC=sigma_s*round((1/2)*sigma(i-1)^2);
        scale_space{i} = PatternCoOcurFilter(prev_im, PatternID_Img,sigma_s,sigma_OC);
    end
end