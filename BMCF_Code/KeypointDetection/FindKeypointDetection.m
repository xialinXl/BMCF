function [keypoints, gradient, angle, Keypoint_Image]=FindKeypointDetection(scale_space_img,scale_ratio,sigma_initial,threshold,AGGREGATE_RESPONSE_THRESHOLD)
    scale_space_img1 = scale_space_img;
    [~,layers] = size(scale_space_img);
    Edge_Image=cell(1,layers);
    for layer = 1:1:layers
       Edge_Image{layer}=EdgeDection(scale_space_img{layer});
    end
    [M, N] = size(scale_space_img{1});
    Keypoint_Image = zeros(M, N, layers);
    gradient = zeros(M, N, layers);
    angle = zeros(M, N, layers);
    for layer = 1:1:layers
        [temp_keypoint_Image, temp_gradient, temp_angle] = KeypointDetectionImage(scale_space_img{layer}, Edge_Image{layer}, scale_ratio, sigma_initial, layer);
        Keypoint_Image(:,:,layer) = temp_keypoint_Image;
        gradient(:,:,layer) = temp_gradient;
        angle(:,:,layer) = temp_angle;
    end
    position = Find_scale_extreme(Keypoint_Image,threshold,sigma_initial,scale_ratio,gradient,angle,AGGREGATE_RESPONSE_THRESHOLD);
    if isempty(position)
        error('未检测到关键点，position为空');
    end
    keypoints=position;
end