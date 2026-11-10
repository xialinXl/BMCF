function threshold_img = GetThresholdImage2(im, threshold_val)
    h1=[-1,0,1;-2,0,2;-1,0,1];
    h2=[-1,-2,-1;0,0,0;1,2,1];
    lp = lowpassfilter([3,3],.45,20);
    gradient_x_0 = imfilter(im, lp, 'replicate');
    gradient_y_0 = imfilter(im, lp, 'replicate');
    gradient_0 = sqrt(gradient_x_0.^2 + gradient_y_0.^2);
    gradient_x_1 = imfilter(gradient_0, h1, 'replicate');
    gradient_y_1 = imfilter(gradient_0, h2, 'replicate');
    gradient_1 = sqrt(gradient_x_1.^2 + gradient_y_1.^2);
    gradient_x_2 = imfilter(gradient_1, h1, 'replicate');
    gradient_y_2 = imfilter(gradient_1, h2, 'replicate');
    gradient_2 = sqrt(gradient_x_2.^2 + gradient_y_2.^2);
    gradient_flat = gradient_2(:);
    non_zero_vals = gradient_flat(gradient_flat > 0);
    [sorted_vals, ~] = sort(non_zero_vals, 'ascend');
    num_pixels = length(sorted_vals);
    threshold_img = false(size(gradient_2));
    if num_pixels > 0
        threshold_index = floor(num_pixels * threshold_val) + 1;
        threshold_value = sorted_vals(threshold_index);
        threshold_img = (gradient_2 >= threshold_value) & (gradient_2 > 0);
    end
end