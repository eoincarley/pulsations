pro plot_hmi_pfss_20140418
	
	cd,'~/Data/2014_apr_18/pulsations/hmi/'
	filename = 'hmi.M_720s.20140418_124800_TAI.1.magnetogram.fits'
	read_sdo, filename, hdr, img, outsize=4096
	;img = rotate(img, 2)
	;index2map, hdr, img, map


	smart_index2map, hdr, img, map
	pixrad = map.rsun/map.cdelt1    
	mask_index = circle_mask(map.data, map.crpix1, map.crpix2, 'GE', pixrad)   
	data_tmp = map.data
	data_tmp[mask_index]  = min(data_tmp)

	unscaled_map = map
	map=map2earth(map)
	map=arm_img_pad(map,/loads)
	FOV = [23, 23] ;[23.0, 23.0] 
    CENTER = [100, -250] ;[150, -200]

    loadct, 0
    window, 0, xs=1000, ys=1000
	plot_map, map, $
		dmin =-5e2, $
		dmax =5e2, $
		fov=FOV, $
		center = center

	plot_helio, hdr.date_obs, $
		/over, $
		gstyle=0, $
		gthick=0.5, $	
		gcolor=255, $
		grid_spacing=15.0	


	oplot_nrh_on_three_color, '2014-04-18T12:55:20'    ;   i_c.date_obs      ;For the 2014-April-Event	

	set_line_color
	restore, '~/Data/2014_apr_18/pulsations/pfss_line_QAR_20140418.sav'
	for i=0, n_elements(xlines_total)-1 do begin
		;plots, xlines, ylines, col=0, thick=8
		xlines = XLINES_TOTAL[i]
		ylines = YLINES_TOTAL[i]
	 	plots, xlines<792, ylines>(-942), col=0, thick=3.5
	 	plots, xlines<792, ylines>(-942), col=10, thick=0.5
    endfor 	


    
STOP    	

	oplot_pfss_20140418	

	;restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src_props_hires_si.sav', /verb	
	;times = anytim(xy_arcs_struct.times, /utim)
	;xarcs = xy_arcs_struct.x_max_fit
	;yarcs = xy_arcs_struct.y_max_fit
	;mean_x = mean(xarcs)
	;mean_y = mean(yarcs)

	;loadct, 1, /silent
	;colors = findgen(n_elements(xarcs))*(255)/(n_elements(xarcs)-1)
	;for i=0, n_elements(xarcs)-1 do begin
	;	plots, xarcs[i], yarcs[i], psym=1, color=colors[i], symsize=0.8, thick=2
		;wait, 0.1
	;endfor	
  
stop
STOP
END
