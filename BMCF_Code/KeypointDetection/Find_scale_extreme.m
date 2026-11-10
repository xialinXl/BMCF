function[key_point_array]=Find_scale_extreme(Keypoint_Image,threshold,sigma,ratio,gradient,angle,AGGREGATE_RESPONSE_THRESHOLD)
    [M,N,num]=size(Keypoint_Image);
    BORDER_WIDTH=12;
    HIST_BIN=36;
    SIFT_ORI_PEAK_RATIO=0.9;
    key_number=0;
    key_point_array=zeros(M,7);
    total_pixels = (M - 2*BORDER_WIDTH + 1) * (N - 2*BORDER_WIDTH + 1);
    cond1_neighbor_fail = 0;
    cond1_scale_fail = 0;
    scale_select_fail = 0;
    maxvalue = max(max(Keypoint_Image(:,:,1)));
    layer_max_values = zeros(1, num);
    for layer=1:num
        layer_max_values(layer) = max(max(Keypoint_Image(:,:,layer)));
    end
    logic_array = zeros(M, N, num);
    for layer=1:num
        temp_current = Keypoint_Image(:,:,layer);
        for j=2:M-1
            for k=2:N-1
                temp = temp_current(j,k);
                if(temp>temp_current(j-1,k-1)&&temp>temp_current(j-1,k)&&temp>temp_current(j-1,k+1)&&...
                    temp>temp_current(j,k-1)&&temp>temp_current(j,k+1)&&...
                    temp>temp_current(j+1,k-1)&&temp>temp_current(j+1,k)&&temp>temp_current(j+1,k+1))
                    logic_array(j,k,layer) = 1;
                end
                if(temp<temp_current(j-1,k-1)&&temp<temp_current(j-1,k)&&temp<temp_current(j-1,k+1)&&...
                    temp<temp_current(j,k-1)&&temp<temp_current(j,k+1)&&...
                    temp<temp_current(j+1,k-1)&&temp<temp_current(j+1,k)&&temp<temp_current(j+1,k+1))
                    logic_array(j,k,layer) = 2;
                end
            end
        end
    end
    for j=BORDER_WIDTH:1:M-BORDER_WIDTH
        for k=BORDER_WIDTH:1:N-BORDER_WIDTH
            responses = squeeze(Keypoint_Image(j,k,:));
            angles = squeeze(angle(j,k,:));
            extreme_layers = zeros(1, num);
            valid_extreme_layers = zeros(1, num);
            extreme_count = 0;
            valid_extreme_count = 0;
            R = squeeze(gradient(j,k,:));
            epsilon = 1e-10;
            for layer=1:num
                if logic_array(j, k, layer) ~= 0
                    extreme_count = extreme_count + 1;
                    extreme_layers(extreme_count) = layer;
                    neighbor_values = [
                        gradient(j-1,k-1,layer), gradient(j-1,k,layer), gradient(j-1,k+1,layer),...
                        gradient(j,k-1,layer),                                gradient(j,k+1,layer),...
                        gradient(j+1,k-1,layer), gradient(j+1,k,layer), gradient(j+1,k+1,layer)
                    ];
                    center_value = gradient(j,k,layer);
                    differences = abs(center_value - neighbor_values);
                    sorted_diffs = sort(differences, 'descend');
                    if length(sorted_diffs) >= 2
                        first_max_diff = sorted_diffs(1);
                        second_max_diff = sorted_diffs(2);
                        layer_max = layer_max_values(layer);
                        if first_max_diff >  threshold
                            valid_extreme_count = valid_extreme_count + 1;
                            valid_extreme_layers(valid_extreme_count) = layer;
                        end
                    end
                end
            end
            if valid_extreme_count == 0
                cond1_neighbor_fail = cond1_neighbor_fail + 1;
                continue;
            end
            valid_extreme_layers = valid_extreme_layers(1:valid_extreme_count);
            S = sum(abs(R));
            S_max = max(abs(R));
            valid_wid = false;
            current_wid = 0;
            if R(layer) > epsilon
                wid = (S / (S_max + epsilon) - 1) / (num - 1);
                current_wid = wid;
                if wid >= AGGREGATE_RESPONSE_THRESHOLD
                    valid_wid = true;
                end
            end
            if ~valid_wid
                cond1_scale_fail = cond1_scale_fail + 1;
                continue;
            end
            best_scale_idx = [];
            max_response = -Inf;
            for scale_idx=valid_extreme_layers
                current_response = gradient(j,k,scale_idx);
                if current_response > max_response
                    max_response = current_response;
                    best_scale_idx = scale_idx;
                end
            end
            if isempty(best_scale_idx)
                scale_select_fail = scale_select_fail + 1;
                continue;
            end
            scale = sigma * ratio^(best_scale_idx - 1);
            gradient_current = gradient(:,:,best_scale_idx);
            angle_current = angle(:,:,best_scale_idx);
            [hist,max_value] = Mycalculate_oritation_hist(k,j,scale,gradient_current,angle_current,HIST_BIN);
            mag_thr = max_value * SIFT_ORI_PEAK_RATIO;
            for kk=1:1:HIST_BIN
                if(kk==1)
                    k1=HIST_BIN;
                else
                    k1=kk-1;
                end
                if(kk==HIST_BIN)
                    k2=1;
                else
                    k2=kk+1;
                end
                if(hist(kk)>hist(k1)&&hist(kk)>hist(k2)...
                    &&hist(kk)>mag_thr)
                    bin=kk-1+0.5*(hist(k1)-hist(k2))/(hist(k1)+hist(k2)-2*hist(kk));
                    if(bin<0)
                        bin=HIST_BIN+bin;
                    elseif(bin>=HIST_BIN)
                        bin=bin-HIST_BIN;
                    end
                    key_number=key_number+1;
                    key_point_array(key_number,1)=k;
                    key_point_array(key_number,2)=j;
                    key_point_array(key_number,3)=sigma*ratio^(best_scale_idx-1);
                    key_point_array(key_number,4)=best_scale_idx;
                    key_point_array(key_number,5)=(360/HIST_BIN)*bin;
                    key_point_array(key_number,6)=hist(kk);
                    key_point_array(key_number,7)=current_wid;
                    break;
                end
            end
        end
    end
    final_key_number = 0;
    if key_number > 0
        key_point_array = key_point_array(1:key_number,:);
        uni1=key_point_array(:,[1,2]);
        [~,i,~]=unique(uni1,'rows','first');
        key_point_array=key_point_array(sort(i)',:);
        final_key_number = size(key_point_array, 1);
        if final_key_number > 5000
            fprintf('特征点数量超过5000，按wid值排序并取前5000个...\n');
            [~, sorted_idx] = sort(key_point_array(:,7), 'descend');
            key_point_array = key_point_array(sorted_idx,:);
            key_point_array = key_point_array(1:5000,:);
            final_key_number = 5000;
        end
        key_point_array = key_point_array(:,1:6);
    else
        key_point_array = [];
    end
    uni1=key_point_array(:,[1,2]);
    [~,i,~]=unique(uni1,'rows','first');
    key_point_array=key_point_array(sort(i)',:);
end