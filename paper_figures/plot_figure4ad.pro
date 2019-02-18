pro setup_ps, name, xsize, ysize

    set_plot,'ps'
    !p.font=0
    !p.charsize=1.7
    device, filename = name, $
        ;/decomposed, $
        /color, $
        /helvetica, $
        /inches, $
        xsize=xsize/100, $
        ysize=xsize/100, $
        /encapsulate, $
        bits_per_pixel=32, $
        yoffset=5

end
			

 pro oplot_radio_src_points, freq, time, color=color

    restore, '~/Data/2014_apr_18/pulsations/nrh_'+freq+'_pulse_src1left_props_hires_si.sav', /verb  
    times = anytim(xy_arcs_struct.times, /utim)
    xarcs = xy_arcs_struct.x_maxtb
    yarcs = xy_arcs_struct.y_maxtb
    plotsym, 0, /fill
    xarcs = xarcs[closest(times, time)]
    yarcs = yarcs[closest(times, time)]
    print, xarcs
    print, yarcs
    plots, xarcs, yarcs, color=0, psym=8, symsize=3, thick=10
    plots, xarcs, yarcs, color=color, psym=8, symsize=1, thick=5

    stop

END

pro plot_figure4ad

	; v2 version attempts to plot NRH 3 color

	restore, '~/Data/2014_apr_18/pulsations/hmi/hmi_map_20140418.sav'
	hmi_map = map
	
    loadct, 0
    window, 0, xs=1000, ys=1000, retain=2

 
  	freqs = [2,4,5]
  	x_size=500 
  	y_size=500
    border = 200.

    folder = '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/'
    cd, folder
    filenames = findfile('*.fts')
    time = anytim('2014-04-18T12:54:00')     ; For the loop, otherwise comment this out and use input time. 
    time_start = anytim('2014-04-18T12:55:28.000') ;
    time_end = anytim('2014-04-18T12:55:40') ;

    ; Just for the purposes of getting hdr
    t0 = anytim(time, /utim)
    t0str = anytim(time_start, /yoh, /time_only)
    t1str = anytim(time_end, /yoh, /time_only)

    read_nrh, filenames[freqs[0]], $
              nrh_hdrs0, $
              nrh_data_cube0, $
              hbeg=t0str, $ 
              hend=t1str

    read_nrh, filenames[freqs[1]], $
              nrh_hdrs1, $
              nrh_data_cube1, $
              hbeg=t0str, $ 
              hend=t1str
              
    read_nrh, filenames[freqs[2]], $
              nrh_hdrs2, $
              nrh_data_cube2, $
              hbeg=t0str, $ 
              hend=t1str                    

    min_scl = 0.8   ; Lower intensity scale on image
    max_scl = 1.0   ; Upper intensity scale on image

    ; Make NRH image same fov as HMI

    nrh_hdr = nrh_hdrs0[0]
    CENTER = [0, 0]  
    hmi_fov = hmi_map.naxis1*hmi_map.cdelt1/hmi_map.rsun*1.0
    fov = [hmi_fov, hmi_fov]

    image_half = (nrh_hdr.naxis1/2.0)*nrh_hdr.cdelt1 
    rsun = nrh_hdr.solar_r
    rsun_fov = hmi_fov/2.0
    xcen0 = (CENTER[0]+image_half)/nrh_hdr.cdelt1  ;nrh_hdr0.crpix1
    ycen0 = (CENTER[1]+image_half)/nrh_hdr.cdelt2   ;nrh_hdr0.crpix2
    pix_fov0 = rsun*rsun_fov
    map_fov0 = ( (2.0*rsun_fov*rsun)*nrh_hdr.cdelt1)/60.0
    img_origin = [-1.0*x_size/2, -1.0*y_size/2]


    for k=0, 7 do begin	
    	nrh_data_orig = nrh_data_cube0[*, *, k]
		nrh_data0 = nrh_data_cube0[*, *, k]/max(nrh_data_cube0[*, *, k])
		nrh_data1 = nrh_data_cube1[*, *, k]/max(nrh_data_cube1[*, *, k])
		nrh_data2 = nrh_data_cube2[*, *, k]/max(nrh_data_cube2[*, *, k])

	    nrh_data0 = nrh_data0[xcen0-pix_fov0:xcen0+pix_fov0, ycen0-pix_fov0:ycen0+pix_fov0]
	    nrh_data1 = nrh_data1[xcen0-pix_fov0:xcen0+pix_fov0, ycen0-pix_fov0:ycen0+pix_fov0]
	    nrh_data2 = nrh_data2[xcen0-pix_fov0:xcen0+pix_fov0, ycen0-pix_fov0:ycen0+pix_fov0]

		max_value = max([nrh_data0, nrh_data1, nrh_data2])
		max_val = max_value*max_scl 
		min_val = max_value*min_scl ;> 1e7
		nrh_data0 = nrh_data0 > min_val < max_val 
		nrh_data1 = nrh_data1 > min_val < max_val
		nrh_data2 = nrh_data2 > min_val < max_val

		nrh_data0 = rebin( congrid(alog10(nrh_data0), 128, 128), hmi_map.naxis1, hmi_map.naxis2)
		nrh_data1 = rebin( congrid(alog10(nrh_data1), 128, 128), hmi_map.naxis1, hmi_map.naxis2) 
		nrh_data2 = rebin( congrid(alog10(nrh_data2), 128, 128), hmi_map.naxis1, hmi_map.naxis2)


	    ;nrh_data0[where(nrh_data0 lt 7)] = 0.0
	    ;nrh_data1[where(nrh_data1 lt 7)] = 0.0
	    ;nrh_data2[where(nrh_data2 lt 7)] = 0.0
	    ; Now perform the zoom. Done with regard to HMI image size, since this is what we're 
	    ; rebbing to.

	    CENTER = [0, -200]
    	fov = [8.25, 8.25]

	    ; 31 pixels per radius. Want to have FOV as 1.3 Rsun (same as AIA). So ~31*1.3 = 40.3
	    ; Have 40.3 pixels on either side of image center to have FOV of 1.3 Rsun. 

	    image_half = (hmi_map.naxis1/2.0)*hmi_map.cdelt1 
	    rsun = hmi_map.rsun
	    rsun_fov = fov[0]*60.0/rsun
	    xcen = (CENTER[0]+image_half)/hmi_map.cdelt1   ;+hmi_map.crpix1
	    ycen = (CENTER[1]+image_half)/hmi_map.cdelt2   ;+hmi_map.crpix2
	    pix_fov = rsun*rsun_fov
	    map_fov = ( (2.0*rsun_fov*rsun)*hmi_map.cdelt1)/60.0
	    img_origin = [-1.0*x_size/2, -1.0*y_size/2]
	    FOV = [map_fov, map_fov]
	    img_num = 0
       
	       
        hmi_data = bytscl(hmi_map.data, -0.3e2, 1e2)
        hmi_data = hmi_data + 1.0e2
        hmi_data = (hmi_data)/max((hmi_data))

        nrh_data0_new = 12.0*nrh_data0 + hmi_data
        nrh_data1_new = 12.0*nrh_data1 + hmi_data
        nrh_data2_new = 12.0*nrh_data2 + hmi_data

        truecolorim = [[[nrh_data0_new]], [[nrh_data1_new]], [[nrh_data2_new]]]
        ; Note there is no control here on indices going outside the array range and producing an error.
        truecolorim_zoom = [[[nrh_data0_new[xcen-pix_fov:xcen+pix_fov, ycen-pix_fov:ycen+pix_fov]]], $
                            [[nrh_data1_new[xcen-pix_fov:xcen+pix_fov, ycen-pix_fov:ycen+pix_fov]]], $
                            [[nrh_data2_new[xcen-pix_fov:xcen+pix_fov, ycen-pix_fov:ycen+pix_fov]]]]

        img = congrid(truecolorim, x_size, y_size, 3)
        img_zoom = congrid(truecolorim_zoom, x_size, y_size, 3)

       		;setup_ps, '~/test.eps', x_size+border, y_size+border ;'+string(i - start_index, format='(I03)' )+'.eps', x_size+border, y_size+border
        setup_ps, '~/Data/2014_apr_18/pulsations/pulse_motion/pulse_motion_'+string(k, format='(I1)')+'.eps', 1200, 1200
        	;setup_ps, '~/Data/2014_apr_18/pulsations/hmi_nrh_zoom2_20140818.eps', 1200, 1200
	        loadct, 0, /silent
	        gamma_ct, 0.6
	        plot_image, img_zoom, true=3, $
	            position=[0.15, 0.15, 0.85, 0.85], $
	            /normal, $
	            xticklen=-0.001, $
	            yticklen=-0.001, $
	            xtickname=[' ',' ',' ',' ',' ',' ',' '], $
	            title = nrh_hdrs0[k].date_obs, $
	            ytickname=[' ',' ',' ',' ',' ',' ',' ']

	        set_line_color    
		    restore, '~/data/2014_apr_18/pulsations/nlfff_lines.sav'
		    for i = 1, n_elements(xlines)-1, 2 do begin
		        ;plots, xlines[i], ylines[i], color=1, thick=1.0
		        plots, xlines[i], ylines[i], color=10, thick=0.5
		    endfor    


	        set_line_color
			;restore, '~/data/2014_apr_18/pulsations/nlfff_lines.sav'
			;for i = 1, n_elements(xlines)-1,2 do plots, xlines[i], ylines[i], color=10, thick=1    	    

	        data = hmi_map.data 
	        data = data < 50.0   ; Just to make sure the map contours of the dummy map don't sow up.
	        hmi_map.data = data
	        levels = [100,100,100]	
			loadct, 3, /silent
	        set_line_color
	        plot_map, hmi_map, $
	            /cont, $
	            levels=levels, $
	            thick=2.5, $
	            color=0, $
	            position=[0.15, 0.15, 0.85, 0.85], $
	            /normal, $
	            /noerase, $
	            /notitle, $
	            xticklen=-0.02, $
	            yticklen=-0.02, $
	            fov = [map_fov, map_fov], $
	            center = CENTER         

	        plot_helio, hmi_map.date_obs, $
	            /over, $
	            gstyle=2, $
	            gthick=1.5, $  
	            gcolor=255, $
	            grid_spacing=15.0  

 
	        ;set_line_color
	        ;freq_string = string(nrh_hdrs0[0].freq, format='(I3)')
	        ;time_ut = anytim(nrh_hdrs0[k].date_obs, /utim)
	        ;oplot_radio_src_points, freq_string, time_ut, color=3	


	        ;----------------------------------------;
	        ;
	        ;nlevels = 5
	        ;top_percent=min_scl  
	  		
	  		;set_line_color
	  		;nrh_data0 = smooth(nrh_data_cube0[*, *, k], 4)
			;index2map, nrh_hdrs0[k], nrh_data0, nrh_map0 	
			;max_val = max(nrh_data0, /nan)
	        ;levels = (findgen(nlevels)*(max_val - max_val*top_percent)/(nlevels-1.0)) + max_val*top_percent 	   
			;plot_map, nrh_map0, /overlay, /cont, levels=levels, /noxticks, /noyticks, /noaxes, thick=1, color=3		
				   
			;nrh_data1 = smooth(nrh_data_cube1[*, *, k], 4)	   
			;index2map, nrh_hdrs1[k], nrh_data1, nrh_map1	
			;max_val = max(nrh_data1, /nan)
	        ;levels = (findgen(nlevels)*(max_val - max_val*top_percent)/(nlevels-1.0)) + max_val*top_percent 	   
			;plot_map, nrh_map1, /overlay, /cont, levels=levels, /noxticks, /noyticks, /noaxes, thick=1, color=4		
				   	
			;nrh_data2 = smooth(nrh_data_cube2[*, *, k], 4)	   	   	
			;index2map, nrh_hdrs2[k], nrh_data2, nrh_map2 	
			;max_val = max(nrh_data2, /nan)
	        ;levels = (findgen(nlevels)*(max_val - max_val*0.3)/(nlevels-1.0)) + max_val*top_percent 	   
			;plot_map, nrh_map2, /overlay, /cont, levels=levels, /noxticks, /noyticks, /noaxes, thick=1, color=5		

			
			;plot_map, nrh_map, $
			;	/overlay, $
			;	/cont, $
			;	levels=levels, $
			;	/noxticks, $
			;	/noyticks, $
			;	/noaxes, $
			;	thick=7, $
			;	color=6		
    
    	;endfor        

		;set_line_color
		;oplot_pfss_20140418	
	   ; device, /close
	   ; set_plot, 'x'
	    
		;restore, '~/Data/2014_apr_18/pulsations/pfss_line_QAR_20140418.sav'
		;for i=0, n_elements(xlines_total)-1 do begin
			;plots, xlines, ylines, col=0, thick=8
		;	xlines = XLINES_TOTAL[i]
		;	ylines = YLINES_TOTAL[i]
			;plots, xlines<792, ylines>(-942), col=0, thick=5.5
		 	;plots, xlines<792, ylines>(-942), col=1, thick=4.5
		 	;plots, xlines<792, ylines>(-942), col=10, thick=3.5

		; 	plots, xlines>(-365)<365, ylines>(-612)<112, col=0, thick=5.5 	;for fov of 12
		; 	plots, xlines>(-365)<365, ylines>(-612)<112, col=1, thick=2.5
		; 	plots, xlines>(-365)<365, ylines>(-612)<112, col=10, thick=1.5

			;plots, xlines>(-322)<222, ylines>(-552)<(-10), col=1, thick=2.5
			;plots, xlines>(-322)<222, ylines>(-552)<(-10), col=10, thick=1.5
	    ;endfor 	  	

	   	;x2png, '~/Desktop/image_'+string(k, format='(I04)' )+'.png'	
    
    device, /close
    set_plot, 'x'


	endfor
STOP
END
