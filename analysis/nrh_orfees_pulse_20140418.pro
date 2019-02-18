pro nrh_orfees_pulse_20140418

	; Simple code to produce images of the pulsations source from 2014-04-18

	folder = '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/' 
	cd, folder
	filenames = findfile('*.fts')
	winsize=600
	window, 0, xs=winsize*2.5, ys=winsize, retain=2

	restore, '~/Data/2014_apr_18/pulsations/pfss_line_QAR_20140418.sav'

	!p.charsize=1.5	
	tstart = anytim('2014-04-18T12:54:30.000', /utim)	;anytim(file2time('20140418_125000'), /utim)	;anytim(file2time('20140418_125546'), /utim)	;anytim(file2time('20140418_125310'), /utim)
	tstop =  anytim('2014-04-18T12:57:30.000', /utim)    ;anytim(file2time('20740418_125440'), /utim)	;anytim(file2time('20140418_125650'), /utim)		;anytim(file2time('20140418_125440'), /utim) 
	FOV = [15, 15]
	CENTER = [0.0, -300.0]
	nlevels=5.0   
	top_percent = 0.4	; Contour levels

	img_num=0
	

	t0str = anytim(tstart, /yoh, /time_only)
	t1str = anytim(tstop, /yoh, /time_only)

	read_nrh, filenames[2], $
			  nrh_hdrs, $
			  nrh_data_cube, $
			  hbeg=t0str, $ 
			  hend=t1str

	;read_nrh, filenames[2], $
	;		  nrhV_hdrs, $
	;		  nrhV_data_cube, $
	;		  hbeg=t0str, $ 
	;		  hend=t1str, $
	;		  /STOKES		  

	freq = nrh_hdrs[0].FREQ

	restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src_props_hires_si.sav', /verb	
	times = anytim(xy_arcs_struct.times, /utim)
	xarcs = xy_arcs_struct.x_max_fit
	yarcs = xy_arcs_struct.y_max_fit
	mean_x = mean(xarcs)
	mean_y = mean(yarcs)

	for k=0, n_elements(nrh_hdrs)-1 do begin		  
			
		nrh_hdr = nrh_hdrs[k]
		nrh_data = nrh_data_cube[*, *, k]
		;nrhV_data = nrhV_data_cube[*, *, k]

		index2map, nrh_hdr, nrh_data, $
				   nrh_map  

		;index2map, nrh_hdr, nrhV_data, $
		;		   nrhV_map  		   
				
		nrh_time = nrh_hdr.date_obs
				
		;------------------------------------;
		;			Plot Total I
		max_val = 1e9;max( (nrh_data), /nan) 
		;min_val_V = min( nrhV_data, /nan)		

		loadct, 3, /silent
		plot_map, nrh_map, $
			fov = FOV, $
			center = CENTER, $
			dmin = 1e7, $
			dmax = 1e9, $
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

		;Vlevels = (dindgen(nlevels)*(min_val_V - min_val_V*top_percent)/(nlevels-1.0)) $
		;		+ min_val_V*top_percent  


		for i=0, n_elements(xlines_total)-1 do begin
			;plots, xlines, ylines, col=0, thick=8
			xlines = XLINES_TOTAL[i]
			ylines = YLINES_TOTAL[i]
         	plots, xlines<450, ylines>(-750)<150, col=10, thick=0.5
        endfor 	
		
		plot_map, nrh_map, $
			/overlay, $
			/cont, $
			levels=levels, $
			/noxticks, $
			/noyticks, $
			/noaxes, $
			thick=3, $
			color=6		


		; Plot a position vector

		;index = closest(nrh_time, anytim(times, /utim))
		;plots, [mean_x, xarcs[index]], [mean_y, yarcs[index]], thick=2
		;plots, [xarcs[index]], [yarcs[index]], thick=2, psym=7, color=3

		;plot_map, nrhV_map, $
		;	/overlay, $
		;	/cont, $
		;	levels=Vlevels, $
		;	/noxticks, $
		;	/noyticks, $
		;	/noaxes, $
		;	thick=2, $
		;	color=5		
	
		orfees_plot_pulsations, 208, anytim(nrh_time, /utim), [tstart, tstop]
		stop
		x2png, '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/image_'+string(img_num, format='(I04)' )+'.png'	
		x2png, '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/image_'+string(img_num+1, format='(I04)' )+'.png'	
		x2png, '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/image_'+string(img_num+2, format='(I04)' )+'.png'	
		x2png, '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/image_'+string(img_num+3, format='(I04)' )+'.png'	
		img_num=img_num+4
				
	endfor				
	spawn, "ffmpeg -y -r 20 -i image_%04d.png -vb 50M test.mpg"
STOP
END