function Filter_img = PatternCoOcurFilter(img, PatternID_Img, params_sigma_s,params_sigma_oc)
    img_min=min(img(:));
    if (img_min<0)
        img=img-img_min;
    end
    sigma_s=params_sigma_s;
    if  isfloat(img)
        img_int32=int32(ceil(img));
    else
        img_int32=img;
    end
    [AdjacencyList,AdjacencyPatternID] = GetAdjacencyList(PatternID_Img);
    assignin('base', 'AdjacencyList', AdjacencyList);
    assignin('base', 'AdjacencyPatternID', AdjacencyPatternID);
    Filter_img = GetFilterImage(img, PatternID_Img, params_sigma_oc, AdjacencyList, AdjacencyPatternID);
end