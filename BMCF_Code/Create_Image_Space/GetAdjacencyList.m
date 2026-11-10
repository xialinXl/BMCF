function [AdjacencyList,AdjacencyPatternID] = GetAdjacencyList(PatternID_Img)
[M, N] = size(PatternID_Img);
unique_ids = unique(PatternID_Img(:));
max_id = max(unique_ids);
AdjacencyList = zeros(max_id + 1, 2^3, 4);
AdjacencyPatternID = zeros(max_id + 1, 2^3, 4);
for id = unique_ids'
    PossiblePatterns = GetPossibleAdjacentPatternID(id);
    AdjacencyPatternID(id + 1, :, 1) = PossiblePatterns(1, :);
    AdjacencyPatternID(id + 1, :, 2) = PossiblePatterns(2, :);
    AdjacencyPatternID(id + 1, :, 3) = PossiblePatterns(3, :);
    AdjacencyPatternID(id + 1, :, 4) = PossiblePatterns(4, :);
end
for y = 1:M
    for x = 1:N
        PatternID = PatternID_Img(y, x);
        if x+1 <= N
            P_r = PatternID_Img(y, x+1);
            idx = find(AdjacencyPatternID(PatternID + 1, :, 1) == P_r, 1);
            if ~isempty(idx)
                AdjacencyList(PatternID + 1, idx, 1) = AdjacencyList(PatternID + 1, idx, 1) + 1;
            end
        end
        if y-1 >= 1
            P_u = PatternID_Img(y-1, x);
            idx = find(AdjacencyPatternID(PatternID + 1, :, 2) == P_u, 1);
            if ~isempty(idx)
                AdjacencyList(PatternID + 1, idx, 2) = AdjacencyList(PatternID + 1, idx, 2) + 1;
            end
        end
        if x-1 >= 1
            P_l = PatternID_Img(y, x-1);
            idx = find(AdjacencyPatternID(PatternID + 1, :, 3) == P_l, 1);
            if ~isempty(idx)
                AdjacencyList(PatternID + 1, idx, 3) = AdjacencyList(PatternID + 1, idx, 3) + 1;
            end
        end
        if y+1 <= M
            P_d = PatternID_Img(y+1, x);
            idx = find(AdjacencyPatternID(PatternID + 1, :, 4) == P_d, 1);
            if ~isempty(idx)
                AdjacencyList(PatternID + 1, idx, 4) = AdjacencyList(PatternID + 1, idx, 4) + 1;
            end
        end
    end
end
for dir = 1:4
    for id = unique_ids'
        row_sum = sum(AdjacencyList(id + 1, :, dir));
        if row_sum > 0
            AdjacencyList(id + 1, :, dir) = AdjacencyList(id + 1, :, dir) / row_sum;
        end
    end
end
end