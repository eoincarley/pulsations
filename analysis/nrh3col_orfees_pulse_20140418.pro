
pro stamp_date_nrh, nrh0, nrh1, nrh2
   
   set_line_color
   !p.charsize = 1.2
   xpos = 0.06
   ypos = 0.95

   ;xyouts, xpos-0.0001, ypos, 'NRH '+string(nrh0.freq, format='(I03)') +' MHz '+anytim(nrh0.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 1
   ;xyouts, xpos+0.0001, ypos, 'NRH '+string(nrh0.freq, format='(I03)') +' MHz '+anytim(nrh0.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 1
   xyouts, xpos, ypos, 'NRH '+string(nrh0.freq, format='(I03)') +' MHz '+anytim(nrh0.date_obs, /cc)+ ' UT', alignment=0, /normal, color = 3
  
   ;xyouts, xpos-0.0001, ypos-0.03, 'NRH '+string(nrh1.freq, format='(I03)') +' MHz '+anytim(nrh1.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 1
   ;xyouts, xpos+0.0001, ypos-0.03, 'NRH '+string(nrh1.freq, format='(I03)') +' MHz '+anytim(nrh1.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 1
   xyouts, xpos, ypos-0.03, 'NRH '+string(nrh1.freq, format='(I03)') +' MHz '+anytim(nrh1.date_obs, /cc)+ ' UT', alignment=0, /normal, color = 4

   ;xyouts, xpos-0.0001, ypos-0.06, 'NRH '+string(nrh2.freq, format='(I03)') +' MHz '+anytim(nrh2.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 1    
   ;xyouts, xpos+0.0001, ypos-0.06, 'NRH '+string(nrh2.freq, format='(I03)') +' MHz '+anytim(nrh2.date_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 1
   xyouts, xpos, ypos-0.06, 'NRH '+string(nrh2.freq, format='(I03)') +' MHz '+anytim(nrh2.date_obs, /cc)+ ' UT', alignment=0, /normal, color = 5
END

pro nrh3col_orfees_pulse_20140418, freqs, x_size, y_size

	; Simple code to produce images of the pulsations source from 2014-04-18

	; nrh_orfees_pulse_20140418.pro but plot a three col image.

  ; nrh3col_orfees_pulse_20140418, [2,3,4], 500, 500

	folder = '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/' 
	cd, folder
	filenames = findfile('*.fts')
	winsize=600
	window, 0, xs=winsize*2.5, ys=winsize, retain=2

    restore, '~/Data/2014_apr_18/pulsations/pfss_line_QAR_20140418.sav'

    border = 200.
    folder = '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/'
    cd, folder
    filenames = findfile('*.fts')
    time = anytim('2014-04-18T12:54:00')     ; For the loop, otherwise comment this out and use input time. 
    time_start = anytim('2014-04-18T12:55:20') ;
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

    min_scl = 0.7   ; Lower intensity scale on image
    max_scl = 1.0   ; Upper intensity scale on image
    CENTER = [0.0, -300.0] 
    ; 31 pixels per radius. Want to have FOV as 1.3 Rsun (same as AIA). So ~31*1.3 = 40.3
    ; Have 40.3 pixels on either side of image center to have FOV of 1.3 Rsun. 
    rsun_fov = 0.4    
    nrh_hdr0 = nrh_hdrs0[0] ; Doesn't matter which header.
    image_half = (nrh_hdr0.naxis1/2.0)*nrh_hdr0.cdelt1 
    xcen = (CENTER[0]+image_half)/nrh_hdr0.cdelt1  ;nrh_hdr0.crpix1
    ycen = (CENTER[1]+image_half)/nrh_hdr0.cdelt2   ;nrh_hdr0.crpix2
    pix_fov = nrh_hdr0.solar_r*rsun_fov
    map_fov = ( (2.0*rsun_fov*nrh_hdr0.solar_r)*nrh_hdr0.cdelt1 )/60.0
    img_origin = [-1.0*x_size/2, -1.0*y_size/2]
    FOV = [map_fov, map_fov]
    img_num = 0

    for k=0, n_elements(nrh_hdrs0)-1 do begin          
            
        nrh_hdr0 = nrh_hdrs0[k]
        nrh_hdr1 = nrh_hdrs1[k]
        nrh_hdr2 = nrh_hdrs2[k]

        nrh_data0 = nrh_data_cube0[*, *, k]
        nrh_data1 = nrh_data_cube1[*, *, k]
        nrh_data2 = nrh_data_cube2[*, *, k]

        nrh_roi0 = nrh_data0[40:70, 40:70]
        nrh_roi1 = nrh_data1[40:70, 40:70]
        nrh_roi2 = nrh_data2[40:70, 40:70]
        max_val0 = max(nrh_roi0)
        max_val1 = max(nrh_roi1)
        max_val2 = max(nrh_roi2)
        max_value = max([nrh_roi0, nrh_roi1, nrh_roi2])
        
        max_val = max_value*max_scl 
        min_val = max_value*min_scl ;> 1e7

        nrh_data0 = nrh_data0 > min_val < max_val 
        nrh_data1 = nrh_data1 > min_val < max_val
        nrh_data2 = nrh_data2 > min_val < max_val

        truecolorim = [[[nrh_data0]], [[nrh_data1]], [[nrh_data2]]]
        ; Note there is no control here on indices going outside the array range and producing an error.
        truecolorim_zoom = [[[nrh_data0[xcen-pix_fov:xcen+pix_fov, ycen-pix_fov:ycen+pix_fov]]], $
                            [[nrh_data1[xcen-pix_fov:xcen+pix_fov, ycen-pix_fov:ycen+pix_fov]]], $
                            [[nrh_data2[xcen-pix_fov:xcen+pix_fov, ycen-pix_fov:ycen+pix_fov]]]]

        img = congrid(truecolorim, x_size, y_size, 3)
        img_zoom = congrid(truecolorim_zoom, x_size, y_size, 3)

        ;setup_ps, '~/test.eps', x_size+border, y_size+border ;'+string(i - start_index, format='(I03)' )+'.eps', x_size+border, y_size+border
        wset, 0
        loadct, 0, /silent
        plot_image, img_zoom, true=3, $
            position=[0.06, 0.15, 0.36, 0.85], $
            /normal, $
            xticklen=-0.001, $
            yticklen=-0.001, $
            xtickname=[' ',' ',' ',' ',' ',' ',' '], $
            ytickname=[' ',' ',' ',' ',' ',' ',' ']

          
        index2map, nrh_hdr0, nrh_data0, map0
        data = map0.data 
        data = data < 50.0   ; Juse to make sure the map contours of the dummy map don't sow up.
        map0.data = data
        levels = [100,100,100]	

		loadct, 3, /silent
		
        set_line_color
        plot_map, map0, $
            /cont, $
            levels=levels, $
            ; /noxticks, $
            ; /noyticks, $
            ; /noaxes, $
            thick=2.5, $
            color=1, $
            position=[0.06, 0.15, 0.36, 0.85], $
            /normal, $
            /noerase, $
            /notitle, $
            xticklen=-0.02, $
            yticklen=-0.02, $
            fov = [map_fov, map_fov], $
            center = CENTER         

        plot_helio, nrh_hdr0.date_obs, $
            /over, $
            gstyle=2, $
            gthick=1.5, $  
            gcolor=255, $
            grid_spacing=15.0 


		for i=0, n_elements(xlines_total)-1 do begin
			;plots, xlines, ylines, col=0, thick=8
			xlines = XLINES_TOTAL[i]
			ylines = YLINES_TOTAL[i]
         	plots, xlines<385, ylines>(-685)<85, col=10, thick=0.5
    endfor 	
		
		;plot_map, map0, $
		;	/overlay, $
		;	/cont, $
		;	levels=levels, $
		;	/noxticks, $
		;	/noyticks, $
		;	/noaxes, $
		;	thick=3, $
		;	color=6		
	
		orfees_plot_pulsations, 208, anytim(nrh_hdr0.date_obs, /utim), [time_start, time_end]

		stamp_date_nrh, nrh_hdr0, nrh_hdr1, nrh_hdr2

		x2png, '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/image_'+string(img_num, format='(I04)' )+'.png'	
		x2png, '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/image_'+string(img_num+1, format='(I04)' )+'.png'	
		;x2png, '~/Data/2014_apr_18/pulsations_results/image_'+string(img_num+2, format='(I03)' )+'.png'	
		img_num=img_num+2

			
	endfor				
	spawn, "ffmpeg -y -r 20 -i image_%04d.png -vb 50M nrh_orfees_"$
		   +string(nrh_hdr0.freq, format='(I3)')+ $
		'.'+string(nrh_hdr1.freq, format='(I3)')+ $
		'.'+string(nrh_hdr2.freq, format='(I3)')+"_pulse_hi_res_stokesi_const_scl_detail2.mpg"
STOP
END