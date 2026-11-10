function[descriptors,locs]=MyGLOH_descriptors(gradient,angle,key_point_array,LOG_POLAR_WIDTH,LOG_POLAR__HIST_BINS)
    M = size(key_point_array,1);
    d = LOG_POLAR_WIDTH;
    n = LOG_POLAR__HIST_BINS;
    descriptors = zeros(M,(3*d+1)*n);
    locs = key_point_array;
    parfor i=1:1:M
        x = key_point_array(i,1);
        y = key_point_array(i,2);
        scale = key_point_array(i,3);
        layer = key_point_array(i,4);
        main_angle = key_point_array(i,5);
        current_gradient = gradient(:,:,layer);
        current_angle = angle(:,:,layer);
        descriptors(i,:) = Mycalc_log_polar_descriptor2(current_gradient,current_angle,x,y,scale,main_angle,d,n);
    end
end