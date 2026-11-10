function PossiblePatterns = GetPossibleAdjacentPatternID(PatternID)
    binary_matrix = zeros(3, 3);
    temp_id = PatternID;
    for i = 3:-1:1
        for j = 3:-1:1
            binary_matrix(i, j) = mod(temp_id, 2);
            temp_id = floor(temp_id / 2);
        end
    end
    PossiblePatterns = zeros(4, 8);
    right_patterns = zeros(1, 8);
    idx = 1;
    for x1 = 0:1
        for x2 = 0:1
            for x3 = 0:1
                new_matrix = [binary_matrix(1, 2), binary_matrix(1, 3), x1;
                            binary_matrix(2, 2), binary_matrix(2, 3), x2;
                            binary_matrix(3, 2), binary_matrix(3, 3), x3];
                right_patterns(idx) = EncodePatternID(new_matrix);
                idx = idx + 1;
            end
        end
    end
    PossiblePatterns(1, :) = sort(right_patterns);
    up_patterns = zeros(1, 8);
    idx = 1;
    for x1 = 0:1
        for x2 = 0:1
            for x3 = 0:1
                new_matrix = [x1, x2, x3;
                            binary_matrix(1, 1), binary_matrix(1, 2), binary_matrix(1, 3);
                            binary_matrix(2, 1), binary_matrix(2, 2), binary_matrix(2, 3)];
                up_patterns(idx) = EncodePatternID(new_matrix);
                idx = idx + 1;
            end
        end
    end
    PossiblePatterns(2, :) = sort(up_patterns);
    left_patterns = zeros(1, 8);
    idx = 1;
    for x1 = 0:1
        for x2 = 0:1
            for x3 = 0:1
                new_matrix = [x1, binary_matrix(1, 1), binary_matrix(1, 2);
                            x2, binary_matrix(2, 1), binary_matrix(2, 2);
                            x3, binary_matrix(3, 1), binary_matrix(3, 2)];
                left_patterns(idx) = EncodePatternID(new_matrix);
                idx = idx + 1;
            end
        end
    end
    PossiblePatterns(3, :) = sort(left_patterns);
    down_patterns = zeros(1, 8);
    idx = 1;
    for x1 = 0:1
        for x2 = 0:1
            for x3 = 0:1
                new_matrix = [binary_matrix(2, 1), binary_matrix(2, 2), binary_matrix(2, 3);
                            binary_matrix(3, 1), binary_matrix(3, 2), binary_matrix(3, 3);
                            x1, x2, x3];
                down_patterns(idx) = EncodePatternID(new_matrix);
                idx = idx + 1;
            end
        end
    end
    PossiblePatterns(4, :) = sort(down_patterns);
    end
    function id = EncodePatternID(matrix)
    id = 0;
    for i = 1:3
        for j = 1:3
            id = id * 2;
            id = id + matrix(i, j);
        end
    end
end