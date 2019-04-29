pro setup_ps, name, xsize, ysize

    set_plot,'ps'
    !p.font=0
    !p.charsize=1.5
    device, filename = name, $
        ;/decomposed, $
        /color, $
        /helvetica, $
        /inches, $
        xsize=xsize/100., $
        ysize=ysize/100., $
        /encapsulate, $
        bits_per_pixel=32, $
        yoffset=5

end


pro plot_supp_movie2_2, postscript=postscript

	; Simple code to produce images of the pulsations source from 2014-04-18

	; This code produces the movies. Apadted from nrh_orfees_pulse_20140418.pro

	folder = '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/' 
	movie_folder = '~/Data/2014_apr_18/pulsations/movie2/
	cd, folder
	filenames = findfile('*.fts')



	restore, '~/Data/2014_apr_18/pulsations/pfss_line_QAR_20140418.sav'
	restore, '~/Data/2014_apr_18/pulsations/hmi/hmi_map_20140418.sav'
	hmi_map = map
	FOV = [23, 23] ;[23.0, 23.0] 
    CENTER = [100, -250] ;[150, -200]

  	freqs = [2,4,5]
  	x_size=500 
  	y_size=500

	folder = '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/' 
	cd, folder
	filenames = findfile('*.fts')

    border = 200.
    folder = '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/'
    cd, folder
    filenames = findfile('*.fts')
    time = anytim('2014-04-18T12:54:00')     ; For the loop, otherwise comment this out and use input time. 
    time_start = anytim('2014-04-18T12:55:20.00') ;
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
    winsize=600
    img_num=0

    restore, '~/Data/2014_apr_18/radio/orfees/orf_20140418_bsubbed_minimum.sav', /verb
    orf_spec = orfees_struct.spec
    orf_time = orfees_struct.time
    orf_freqs = reverse(orfees_struct.freq)

    restore, '~/data/2014_apr_18/pulsations/nlfff_lines.sav'

    for k=0, n_elements(nrh_hdrs0)-1 do begin	

    	if keyword_set(postscript) then begin
			;img_name = movie_folder+ 'image_'+string(img_num, format='(I04)' )+'.eps'	
            img_name = '~/image_'+string(img_num, format='(I04)' )+'.eps'   
			setup_ps, img_name, 1.5*winsize*2.5, 1.5*winsize
		endif else begin
			window, 0, xs=winsize*2.5, ys=winsize, retain=2
		endelse	

        nrh_time = nrh_hdrs0[k].date_obs
    	nrh_data_orig = nrh_data_cube0[*, *, k]
        nrh_data0 = nrh_data_cube0[*, *, k]/max(nrh_data_cube0[*, *, k])
        nrh_data1 = nrh_data_cube1[*, *, k]/max(nrh_data_cube1[*, *, k])
        nrh_data2 = nrh_data_cube2[*, *, k]/max(nrh_data_cube2[*, *, k])

        nrh_data0 = nrh_data0[xcen0-pix_fov0:xcen0+pix_fov0, ycen0-pix_fov0:ycen0+pix_fov0]
        nrh_data1 = nrh_data1[xcen0-pix_fov0:xcen0+pix_fov0, ycen0-pix_fov0:ycen0+pix_fov0]
        nrh_data2 = nrh_data2[xcen0-pix_fov0:xcen0+pix_fov0, ycen0-pix_fov0:ycen0+pix_fov0]

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
        ;img_num = 0
       
    
            max_value = max([nrh_data0, nrh_data1, nrh_data2])
            max_val = max_value*max_scl 
            min_val = max_value*min_scl ;> 1e7
            nrh_data0 = nrh_data0 > min_val < max_val 
            nrh_data1 = nrh_data1 > min_val < max_val
            nrh_data2 = nrh_data2 > min_val < max_val

            nrh_data0 = rebin( congrid(alog10(nrh_data0), 128, 128), hmi_map.naxis1, hmi_map.naxis2)
            nrh_data1 = rebin( congrid(alog10(nrh_data1), 128, 128), hmi_map.naxis1, hmi_map.naxis2) 
            nrh_data2 = rebin( congrid(alog10(nrh_data2), 128, 128), hmi_map.naxis1, hmi_map.naxis2)
         
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
                ;setup_ps, '~/Data/2014_apr_18/pulsations/pulse_motion/pulse_motion_'+string(k, format='(I1)')+'.eps', 1200, 1200
                ;setup_ps, '~/Data/2014_apr_18/pulsations/hmi_nrh_zoom2_20140818.eps', 1200, 1200
            loadct, 0, /silent
            gamma_ct, 0.6
            plot_image, img_zoom, true=3, $
                position=[0.06, 0.15, 0.36, 0.85], $
                /normal, $
                xticklen=-0.001, $
                yticklen=-0.001, $
                xtickname=[' ',' ',' ',' ',' ',' ',' '], $
                title = nrh_hdrs0[k].date_obs, $
                ytickname=[' ',' ',' ',' ',' ',' ',' ']

            set_line_color
            for i = 1, n_elements(xlines)-1,2 do plots, xlines[i], ylines[i], color=10, thick=1         

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
                position=[0.06, 0.15, 0.36, 0.85], $
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

		orfees_plot_pulsations, [208, 298, 327], anytim(nrh_time, /utim), [time_start, time_end], orf_spec, orf_time, orf_freqs

		if keyword_set(postscript) then begin
			device, /close
			png_name = movie_folder+'image_'+string(img_num, format='(I04)' )+'.png'
			spawn, 'convert -density 70 '+img_name+' -flatten '+png_name
			spawn, 'rm '+img_name
			spawn,'cp '+png_name+' '+movie_folder+'image_'+string(img_num+1, format='(I04)' )+'.png'
			spawn,'cp '+png_name+' '+movie_folder+'image_'+string(img_num+2, format='(I04)' )+'.png'
			spawn,'cp '+png_name+' '+movie_folder+'image_'+string(img_num+3, format='(I04)' )+'.png'
		endif	
		;x2png, '~/Data/2014_apr_18/pulsations/movies_extended/image_'+string(img_num, format='(I04)' )+'.png'	
			;x2png, '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/image_'+string(img_num+1, format='(I04)' )+'.png'	
			;x2png, '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/image_'+string(img_num+2, format='(I04)' )+'.png'	
			;x2png, '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/image_'+string(img_num+3, format='(I04)' )+'.png'	
		img_num=img_num+4.0	

	endfor			
	spawn, "ffmpeg -y -r 20 -i image_%04d.png -vb 50M pulse_zoom_movie.mpg"
STOP
END