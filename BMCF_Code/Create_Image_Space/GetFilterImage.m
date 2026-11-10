function Filter_img = GetFilterImage2(img, PatternID_Img, params_sigma_oc, AdjacencyList, AdjacencyPatternID)
    img = double(img);
    sigma_s = params_sigma_oc;
    [M, N] = size(img);
    win_size=3*sigma_s;
    win_halfsize=ceil(win_size/2);
    win_size=win_halfsize*2+1;
    [prob_right, prob_up, prob_left, prob_down] = ComputeDirectionalProbs(PatternID_Img, AdjacencyList, AdjacencyPatternID);
    prob_right_pad = padarray(prob_right, [win_halfsize, win_halfsize], 0, 'both');
    prob_up_pad = padarray(prob_up, [win_halfsize, win_halfsize], 0, 'both');
    prob_left_pad = padarray(prob_left, [win_halfsize, win_halfsize], 0, 'both');
    prob_down_pad = padarray(prob_down, [win_halfsize, win_halfsize], 0, 'both');
    img_pad = padarray(img, [win_halfsize, win_halfsize], 0, 'both');
    Filter_img = zeros(M, N);
    for i = 1:M
        for j = 1:N
            center_i = i + win_halfsize;
            center_j = j + win_halfsize;
            weight_window = zeros(win_size, win_size);
            img_sub = img_pad(i:i+win_size-1, j:j+win_size-1);
            chain_prob = 1;
            for dx = 1:win_halfsize
                if center_j + dx <= size(prob_right_pad, 2)
                    chain_prob = chain_prob * prob_right_pad(center_i, center_j + dx - 1);
                    weight_window(win_halfsize + 1, win_halfsize + 1 + dx) = chain_prob;
                end
            end
            chain_prob = 1;
            for dx = -1:-1:-win_halfsize
                if center_j + dx >= 1
                    chain_prob = chain_prob * prob_left_pad(center_i, center_j + dx + 1);
                    weight_window(win_halfsize + 1, win_halfsize + 1 + dx) = chain_prob;
                end
            end
            chain_prob = 1;
            for dy = -1:-1:-win_halfsize
                if center_i + dy >= 1
                    chain_prob = chain_prob * prob_up_pad(center_i + dy + 1, center_j);
                    weight_window(win_halfsize + 1 + dy, win_halfsize + 1) = chain_prob;
                end
            end
            chain_prob = 1;
            for dy = 1:win_halfsize
                if center_i + dy <= size(prob_down_pad, 1)
                    chain_prob = chain_prob * prob_down_pad(center_i + dy - 1, center_j);
                    weight_window(win_halfsize + 1 + dy, win_halfsize + 1) = chain_prob;
                end
            end
            for dx = 1:win_halfsize
                for dy = 1:win_halfsize
                    weight_window(win_halfsize + 1 - dy,win_halfsize + 1 + dx) = weight_window(win_halfsize + 1 - dy+1,win_halfsize + 1 + dx)*prob_up_pad(center_i-dy, center_j+dx)/2+weight_window(win_halfsize + 1 - dy,win_halfsize + 1 + dx-1)*prob_right_pad(center_i-dy, center_j+dx)/2;
                    weight_window(win_halfsize + 1 - dy,win_halfsize + 1 - dx) = weight_window(win_halfsize + 1 - dy+1,win_halfsize + 1 - dx)*prob_up_pad(center_i-dy, center_j-dx)/2+weight_window(win_halfsize + 1 - dy,win_halfsize + 1 - dx+1)*prob_left_pad(center_i-dy, center_j-dx)/2;
                    weight_window(win_halfsize + 1 + dy,win_halfsize + 1 - dx) = weight_window(win_halfsize + 1 + dy-1,win_halfsize + 1 - dx)*prob_down_pad(center_i+dy, center_j-dx)/2+weight_window(win_halfsize + 1 + dy,win_halfsize + 1 - dx+1)*prob_left_pad(center_i+dy, center_j-dx)/2;
                    weight_window(win_halfsize + 1 + dy,win_halfsize + 1 + dx) = weight_window(win_halfsize + 1 + dy-1,win_halfsize + 1 + dx)*prob_down_pad(center_i+dy, center_j+dx)/2+weight_window(win_halfsize + 1 + dy,win_halfsize + 1 + dx-1)*prob_right_pad(center_i+dy, center_j+dx)/2;
                end
            end
            weight_window(win_halfsize + 1, win_halfsize + 1) = 1;
            Filter_img(i, j) = sum(img_sub(:) .* weight_window(:))/sum(weight_window(:)+eps);
        end
    end
end