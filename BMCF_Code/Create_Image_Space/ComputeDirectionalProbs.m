function [prob_right, prob_up, prob_left, prob_down] = ComputeDirectionalProbs(PatternID_Img, AdjacencyList, AdjacencyPatternID)
    [M, N] = size(PatternID_Img);
    prob_right = zeros(M, N);
    prob_up = zeros(M, N);
    prob_left = zeros(M, N);
    prob_down = zeros(M, N);
    for i = 1:M
        for j = 1:N
            center_id = PatternID_Img(i, j);
            if j < N
                right_id = PatternID_Img(i, j + 1);
                dir = 1;
                [~, idx] = ismember(right_id, squeeze(AdjacencyPatternID(center_id + 1, :, dir)));
                if idx > 0
                    prob_right(i, j) = AdjacencyList(center_id + 1, idx, dir);
                end
            end
            if i > 1
                up_id = PatternID_Img(i - 1, j);
                dir = 2;
                [~, idx] = ismember(up_id, squeeze(AdjacencyPatternID(center_id + 1, :, dir)));
                if idx > 0
                    prob_up(i, j) = AdjacencyList(center_id + 1, idx, dir);
                end
            end
            if j > 1
                left_id = PatternID_Img(i, j - 1);
                dir = 3;
                [~, idx] = ismember(left_id, squeeze(AdjacencyPatternID(center_id + 1, :, dir)));
                if idx > 0
                    prob_left(i, j) = AdjacencyList(center_id + 1, idx, dir);
                end
            end
            if i < M
                down_id = PatternID_Img(i + 1, j);
                dir = 4;
                [~, idx] = ismember(down_id, squeeze(AdjacencyPatternID(center_id + 1, :, dir)));
                if idx > 0
                    prob_down(i, j) = AdjacencyList(center_id + 1, idx, dir);
                end
            end
        end
    end
end