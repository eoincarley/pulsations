pro setup_ps, name, xsize, ysize

    set_plot,'ps'
    !p.font=0
    !p.charsize=1.7
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


pro plot_supp_movie1_extended, postscript=postscript

	; Simple code to produce images of the pulsations source from 2014-04-18

	; This code produces the movies. Apadted from nrh_orfees_pulse_20140418.pro

    folder = '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/' 
    movie_folder = '~/Data/2014_apr_18/pulsations/movie1/
    cd, folder
    filenames = findfile('*.fts')

    restore, '~/Data/2014_apr_18/pulsations/pfss_line_QAR_20140418.sav'

    orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
    restore, orfees_folder+'orf_20140418_bsubbed_minimum.sav', /verb
    orf_spec = orfees_struct.spec
    orf_time = orfees_struct.time
    orf_freqs = orfees_struct.freq
    orf_freqs = reverse(orf_freqs)


    !p.charsize=1.5 
    time_start = anytim('2014-04-18T12:53:00.000', /utim)   ;anytim(file2time('20140418_125000'), /utim)    ;anytim(file2time('20140418_125546'), /utim)    ;anytim(file2time('20140418_125310'), /utim)
    time_end =  anytim('2014-04-18T12:58:30.000', /utim)    ;anytim(file2time('20740418_125440'), /utim)   ;anytim(file2time('20140418_125650'), /utim)        ;anytim(file2time('20140418_125440'), /utim) 
    FOV = [20, 20]
    CENTER = [0.0, -300.0]
    nlevels=5.0   
    top_percent = 0.4   ; Contour levels    

    t0str = anytim(time_start, /yoh, /time_only)
    t1str = anytim(time_end, /yoh, /time_only)

    read_nrh, filenames[5], $
              nrh_hdrs, $
              nrh_data_cube, $
              hbeg=t0str, $ 
              hend=t1str

    freq = nrh_hdrs[0].FREQ
    winsize=600
    img_num=0.0
    window, 0, xs=winsize*2.5, ys=winsize, retain=2

    for k=0, n_elements(nrh_hdrs)-1 do begin	

    	if keyword_set(postscript) then begin
			img_name = movie_folder+ 'image_'+string(img_num, format='(I04)' )+'.eps'	
			setup_ps, img_name, 1.5*winsize*2.5, 1.5*winsize
		endif else begin
			wset, 0;, xs=winsize*2.5, ys=winsize, retain=2
		endelse	

    	nrh_hdr = nrh_hdrs[k]
        nrh_data = nrh_data_cube[*, *, k]

        index2map, nrh_hdr, nrh_data, $
                   nrh_map  
                
        nrh_time = nrh_hdr.date_obs
                
        ;------------------------------------;
        ;           Plot Total I
        max_val = max( (nrh_data), /nan) ;1e9
        ;min_val_V = min( nrhV_data, /nan)      

        loadct, 3, /silent
        plot_map, nrh_map, $
            fov = FOV, $
            center = CENTER, $
            dmin = 1e7, $
            dmax = 1e9, $
            charsize = 1.3, $
            title='NRH '+string(freq, format='(I03)')+' MHz '+ $
            string( anytim( nrh_time, /yoh) )+' UT', $
            position=[0.06, 0.15, 0.36, 0.85], $
            /normal
    
        set_line_color
        plot_helio, nrh_time, $
            /over, $
            gstyle=1, $
            gthick=1.0, $
            gcolor=4, $
            grid_spacing=15.0
                                       
        levels = (findgen(nlevels)*(max_val - max_val*top_percent)/(nlevels-1.0)) $
                + max_val*top_percent  


        plot_map, nrh_map, $
            /overlay, $
            /cont, $
            levels=levels, $
            /noxticks, $
            /noyticks, $
            /noaxes, $
            thick=1, $
            color=6            

		for i=0, n_elements(xlines_total)-1 do begin
			xlines = XLINES_TOTAL[i]
			ylines = YLINES_TOTAL[i]
		 	plots, xlines, ylines, col=1, thick=1.5
		 	plots, xlines, ylines, col=10, thick=0.5
	    endfor 	  			

		orfees_plot_pulsations, freq, anytim(nrh_time, /utim), [time_start, time_end], orf_spec, orf_time, orf_freqs
		
		if keyword_set(postscript) then begin
			device, /close
			png_name = movie_folder+'image_'+string(img_num, format='(I04)' )+'.png'
			spawn, 'convert -density 70 '+img_name+' -flatten '+png_name
			spawn, 'rm '+img_name
			;spawn,'cp '+png_name+' '+movie_folder+'image_'+string(img_num+1, format='(I04)' )+'.png'
			;spawn,'cp '+png_name+' '+movie_folder+'image_'+string(img_num+2, format='(I04)' )+'.png'
		endif	
			x2png, '~/Data/2014_apr_18/pulsations/movie1/image_'+string(img_num, format='(I04)' )+'.png'	
			;x2png, '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/image_'+string(img_num+1, format='(I04)' )+'.png'	
			;x2png, '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/image_'+string(img_num+2, format='(I04)' )+'.png'	
			;x2png, '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/image_'+string(img_num+3, format='(I04)' )+'.png'	
		img_num=img_num+1.0	
	endfor		
    cd,'~/Data/2014_apr_18/pulsations/movie1/'
	spawn, "ffmpeg -y -r 20 -i image_%04d.png -vb 50M nrh_orfees_"+string(freq, format='(I03)')+"_pulse_extended.mpg"
    spawn,'rm image_*.png'
STOP
END