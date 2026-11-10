function [Edge_Image] = EdgeDection(Filter_img)
    Edge_Image=Filter_img;
    max_Pixel=max(Filter_img(:));
    min_Pixel=min(Filter_img(:));
    Edge_Count=zeros(size(Filter_img));
    [M,N] = size(Filter_img);
    for p=min_Pixel:1:max_Pixel
        temp_greater_img = (Filter_img>=p);
        temp_greater_pad = padarray(temp_greater_img,[1 1],'replicate');
        diff_Img = false(size(Filter_img));
        for di=1:1:3
            for dj=1:1:3
                if di == 2 && dj == 2
                    continue;
                end
                dv_im = temp_greater_pad(di:di+M-1,dj:dj+N-1);
                diff_Img = diff_Img | (temp_greater_img & (dv_im ~= temp_greater_img));
            end
        end
        Edge_Count = Edge_Count + diff_Img;
    end
    Edge_Image=Edge_Count;
end