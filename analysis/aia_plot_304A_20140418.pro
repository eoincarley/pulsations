pro aia_plot_304A_20140418, total_b=total_b, ratio=ratio

	files = file_search('~/Data/2014_apr_18/sdo/304A/*.fits')
	FOV = [5, 5] ;[23.0, 23.0] 
	CENTER = [-100, -250] ;[150, -200]

	for i=5, n_elements(files)-1 do begin

		aia_prep, files[i], -1, hdr, img, /uncomp_delete, /norm

	    if keyword_set(total_b) then begin
	        iscaled_img = img
	        undefine, img
	        ;iscaled_img = ( iscaled_img - mean(iscaled_img) ) /stdev(iscaled_img)   	   
	        iscaled_img = iscaled_img > (-100.0) < 100.0  ; -1, 6 
	    endif   

	    if keyword_set(ratio) then begin
	    	aia_prep, files[i-5], -1, hdr_pre, img_pre, /uncomp_delete, /norm
	        iscaled_img = img/img_pre;smooth(img, 1)/smooth(img_pre, 51)
	        undefine, img
	        undefine, img_pre
	        iscaled_img = iscaled_img > (0.5) < 1.5;
	    endif   

	    index2map, hdr, iscaled_img, map

	    loadct, 3
	    gamma_ct, 0.38
	    window, 0, xs=1000, ys=1000, retain=2
		plot_map, map, $
			fov=FOV, $
			center = center

        plot_helio, hdr.date_obs, $
             /over, $
             gstyle=0, $
             gthick=1, $  
             gcolor=0, $
             grid_spacing=15.0     
    	

        x2png, '~/Data/2014_apr_18/pulsations/aia.304.tb/image_'+string(i-5, format='(I03)' )+'.png'
        
	 endfor   

END