function PatternID_Img = GetPatternID(E_img)
    [M, N] = size(E_img);
    PatternID_Img = zeros(M, N);
    E_padded = padarray(E_img, [1,1], 'symmetric', 'both');
    for dy = -1:1
        for dx = -1:1
            startX = dx+2;
            startY = dy+2;
            endX = startX -1 + N;
            endY = startY -1 + M;
            Current_E = E_padded(startY:endY, startX:endX);
            PatternID_Img = PatternID_Img.*2;
            PatternID_Img = PatternID_Img + Current_E;
        end
    end
end