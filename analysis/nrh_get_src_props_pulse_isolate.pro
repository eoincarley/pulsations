function my2Dgauss, x, y, pars

	;This is for use in mpfit2dfun below
	;result_pars = MPFIT2DFUN('my2Dgauss', xjunk, yjunk, junk_array, ERR, $
	;		start_parms, perror=perror, yfit=yfit)

	z = dblarr(n_elements(x),n_elements(y))

	FOR i = 0, n_elements(x)-1.0 DO BEGIN
		FOR j=0, n_elements(y)-1.0 DO BEGIN
			T = pars[6]
			xp = (x[i]-pars[4])*cos(T) - (y[j]-pars[5])*sin(T)
			yp = (x[i]-pars[4])*sin(T) - (y[j]-pars[5])*cos(T)
			U = (xp/pars[2])^2.0 + (yp/pars[3])^2.0
			z[i,j] = pars[0] + pars[1]*exp(-U/2.0)
		ENDFOR
	ENDFOR	

	return, z

END

pro calculate_flux, source_section, freq, $
					flux, max_tb
	

	Ray = 32.0							; Solar_R in nrh_hdr_array
	domega = FLOAT(16 * 3E-4 /Ray)^2. 	; Solid angle. Below is a summation of pixels of Tb, which is effectively and integral
										; of Tbx1unit pixels. We need an integral of TbxDomega. So after the summation of Tb
										; we multiply by a factor of solid angle per pixel. 16 here is degrees of solar radius.
										; 32 is number of pixels per radius. 3e-14 comes from (1/60)x(pi/180), conversion of degrees
										; then to radians.
	c = 299792458. 						; speed of light in m/s
	k_B = 0.138							; Boltzmann constant k=1.38e-23, for SFU: K*e+22

	loadct, 1, /silent
	wset, 5
	plot_image, source_section > 1e6, title='Flux calculation'

	; Find the max point and mark with a diamond
	index_max = where(source_section eq max(source_section))	; Stokes I.
	;index_max = where(source_section eq min(source_section))	; Stokes V.
	xy_max = array_indices(source_section, index_max)
	plots, xy_max[0, *], xy_max[1, *], /data, psym=4, color=4
	max_tb = source_section[index_max]

	; Find points above 0.4 of max and mark with cross.
	indices = where(source_section ge max(source_section)*0.5)	; Stokes I.
	;indices = where(source_section le min(source_section)*0.5)	; Stokes V.
	if n_elements(indices) eq 1 then indices=0
	xy_indices = array_indices(source_section, indices)

	set_line_color
	plots, xy_indices[0, *], xy_indices[1, *], /data, psym=1, color=3

	total_Tb = TOTAL(source_section[indices])		;summing over specified source are					
	lambda = c / freq
	constant = (2.* k_B * domega) / (lambda^2.)
	flux = constant * total_Tb	; in SFU


END

pro plot_nrh_data, nrh_map, FOV, CENTER, freq, nrh_time, clevels

	plot_map, nrh_map, $
		fov = FOV, $
		center = CENTER, $
		dmin = 1e6, $
		dmax = 3e8, $
		title='NRH '+string(freq, format='(I03)')+' MHz '+ $
		string( anytim( nrh_time, /yoh) )+' UT', $
		pos=[0.15, 0.15, 0.85, 0.85], $
		/normal
		  
	set_line_color
	plot_helio, nrh_time, $
		/over, $
		gstyle=1, $
		gthick=1.0, $
		gcolor=4, $
		grid_spacing=15.0
								   

	plot_map, nrh_map, $
		/overlay, $
		/cont, $
		levels=clevels, $
		/noxticks, $
		/noyticks, $
		/noaxes, $
		thick=1, $
		color=5		

	loadct, 3, /silent	

END

pro nrh_get_src_props_pulse_isolate, save_props=save_props

	; Code to firstly choose the source. A 2D Gaussian is then fit to the source, the 
	; paramaters of which are saved. The source flux and brighness temperature are also
	; saved.
	; data_folder = '~/Data/2014_sep_01/radio/nrh/clean_wresid' 

	; Copy of nrh_get_src_props.pro, but this one is tailored to analyse the pulsation source.

	; _isolate zeros a section of the array where a second nearby source is interupting the calcuation.

	winsize=300
	xpos=900
	ypos=500
	window, 0, xs=winsize, ys=winsize, xpos=xpos, ypos=ypos, retain=2
	window, 1, xs=winsize, ys=winsize, xpos=xpos, ypos=ypos-winsize*1.4, retain=2
	winsize=250
	window, 2, xs=winsize, ys=winsize, xpos=xpos-winsize*1.1, ypos=ypos, retain=2
	window, 3, xs=winsize, ys=winsize, xpos=xpos-winsize*1.1, ypos=ypos-winsize, retain=2
	window, 4, xs=winsize, ys=winsize, xpos=xpos-winsize*1.1, ypos=ypos-winsize*2, retain=2
	window, 5, xs=winsize, ys=winsize, xpos=xpos-winsize*1.1, ypos=ypos-winsize*3, retain=2
	!p.charsize=1.5
	
	folder = '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/' 
	cd, folder
	filenames = findfile('*.fts')
	FOV = [15, 15]	; [12, 12]
	CENTER = [-100.0, -300.0]	; [0, -300]
	nlevels=5.0   
	top_percent = 0.50
	first_values=0
	zoom_sz = 16	; 12 for tge 228 MHz
	junk_arr_sz = 50.	; For a succesful Gaussian fit, source needs to be in a relatively large array of background values. Here array size 50 is chosen.
	junk_arr_halfsz = junk_arr_sz/2.

	tstart = anytim('2014-04-18T12:53:00.000', /utim)	 ;anytim(file2time('20140418_125000'), /utim)	;anytim(file2time('20140418_125546'), /utim)	;anytim(file2time('20140418_125310'), /utim)
	tstop =  anytim('2014-04-18T12:58:00.000', /utim)    ;anytim(file2time('20740418_125440'), /utim)	;anytim(file2time('20140418_125650'), /utim)		;anytim(file2time('20140418_125440'), /utim) 
	t0str = anytim(tstart, /yoh, /time_only)
	t1str = anytim(tstop, /yoh, /time_only)

	read_nrh, filenames[7], $		; CHOOSE FILE
			  nrh_hdrs, $
			  nrh_data_cube, $
			  hbeg=t0str, $ 
			  hend=t1str;, $
			  ;/STOKES

	x0 = ( (CENTER[0]/nrh_hdrs[0].cdelt1 + (nrh_hdrs[0].naxis1/2.0)) - (FOV[0]*60.0/nrh_hdrs[0].cdelt1)/2.0 )
	x1 = ( (CENTER[0]/nrh_hdrs[0].cdelt1 + (nrh_hdrs[0].naxis1/2.0)) + (FOV[0]*60.0/nrh_hdrs[0].cdelt1)/2.0 )
	y0 = ( (CENTER[1]/nrh_hdrs[0].cdelt2 + (nrh_hdrs[0].naxis2/2.0)) - (FOV[1]*60.0/nrh_hdrs[0].cdelt2)/2.0 )
	y1 = ( (CENTER[1]/nrh_hdrs[0].cdelt2 + (nrh_hdrs[0].naxis2/2.0)) + (FOV[1]*60.0/nrh_hdrs[0].cdelt2)/2.0 )	  
	freq = nrh_hdrs[0].FREQ

	; Produce a mask for zeroing a certain source.
	mask = findgen(x1-x0+1.0, y1-y0+1.0)
	mask[*]=1.0
	x = indgen(35)
	y = 20.0 - 1.0*x > 0.0	; Set this line to use in for loop
	r = sqrt(x^2 + y^2)
	for i=0, n_elements( mask[0,*] )-1 do begin
		for j=0, n_elements(mask[*, 0])-1 do begin
			rindex = sqrt(i^2 + j^2)
			if rindex lt r[i] then mask[i, j]=0.0	; Anything below the line is zeroed.
		endfor
	endfor

	restore, '~/Data/2014_apr_18/pulsations/pfss_line_QAR_20140418.sav'
	for img_num=0, n_elements(nrh_hdrs)-1 do begin		  
			
		nrh_hdr = nrh_hdrs[img_num]
		nrh_data = nrh_data_cube[*, *, img_num]
		index2map, nrh_hdr, nrh_data, nrh_map  
		nrh_time = nrh_hdr.date_obs
				
		;------------------------------------;
		;		  Plot img arcsec
		loadct, 3, /silent
		wset, 0
		max_val = max( (nrh_data), /nan) 		
		clevels = (dindgen(nlevels)*(max_val - max_val*top_percent)/(nlevels-1.0)) + max_val*top_percent  
		plot_nrh_data, nrh_map, FOV, CENTER, freq, nrh_time, clevels

		for i=0, n_elements(xlines_total)-1 do begin
			set_line_color
			xlines = XLINES_TOTAL[i]
			ylines = YLINES_TOTAL[i]
			plots, xlines<792, ylines>(-942), col=10, thick=0.5
	    endfor

		;------------------------------------;
		;	 	   Plot img pixels			 ;
		loadct, 2, /silent
		wset, 1
		data_section = nrh_data[x0:x1, y0:y1]
		data_section = mask*data_section
		plot_image, data_section, $	; > (1e6) < 3e8, $
			title='Raw data, pixel numbers.', $
			pos=[0.15, 0.15, 0.85, 0.85], $
			/normal

		;data_section = abs(data_section<0.0)	; Invert negative STOKES V source to make life easier.

		;if img_num eq 0 then begin   ; Implent this if statement if source is stationary and easy to track automatically
		;	print, 'Choose approximate source centroid.'
		;	cursor, source_x, source_y, /data
		;endif else begin	
			source_x = 20.0	;max_tb_x + x0zoom
			source_y = 15.0	;max_tb_y + y0zoom
		;endelse 

		source_x = fix(source_x)
		source_y = fix(source_y)
		;------------------------------------------------------;
		;  Extract src plus a small section around that source
		x0zoom = (source_x-zoom_sz > 0 < ((size(data_section))[1]-1) )
		x1zoom = (source_x+zoom_sz > 0 < ((size(data_section))[1]-1) )
		y0zoom = (source_y-zoom_sz > 0 < ((size(data_section))[2]-1) )
		y1zoom = (source_y+zoom_sz > 0 < ((size(data_section))[2]-1) )
		source_section = data_section[x0zoom:x1zoom, y0zoom:y1zoom] 

		source_section[ 23:n_elements(source_section[*,0])-1, * ] = 0.0;min(source_section)	; Try and zero the second source.

		x_len = (size(source_section))[1]
		y_len = (size(source_section))[2]
		junk_array = dblarr(x_len+junk_arr_sz, y_len+junk_arr_sz) 
		junk_array[*] = 0.0;mean(source_section)	; The backround logTb value. 6 for >= 228 MHz
		junk_array[ junk_arr_halfsz:junk_arr_halfsz+x_len-1, $
					junk_arr_halfsz:junk_arr_halfsz+y_len-1] = source_section/1e8

		;junk_array = junk_array/1e8
		
		;--------------------------------------------------------;
		;	 Plot surface of source + empty background values	 ;
		;
		wset, 2
		shade_surf, junk_array
		poor_src_sz = n_elements( where(junk_array gt 0.5*max(junk_array) ) )*nrh_hdrs[0].cdelt1^2.0	; Poor man's source size, Stokes I.
		;poor_src_sz = n_elements( where(junk_array lt 0.5*min(junk_array) ) )*nrh_hdrs[0].cdelt1^2.0	; Poor man's source size. Stokes V.

		;---------------------------------------;
		;			Fit 2D Gaussian 
		;
		if img_num eq 0 then begin
			;Since gauss2dfit doens't give errors, use fit_params_v0 as start values
			;for mpfit2dfun (which provides ucnertainties).
			result_0 = gauss2dfit(junk_array, fit_params_v0, /tilt)
			start_parms = fit_params_v0
		endif else begin
			start_parms = result_pars
		endelse	

		xjunk = dindgen( n_elements(junk_array[*,0]) )
		yjunk = dindgen( n_elements(junk_array[0,*]) )
		result_pars = MPFIT2DFUN('my2Dgauss', xjunk, yjunk, junk_array, ERR, status=status, $
			start_parms, perror=perror, yfit=yfit)


		if status le 0 or status eq 5 then begin	; If fit error then skip
			print, 'Failed to converge'
		endif else begin
			loadct, 3, /silent
			wset, 3	
			plot_image, sigrange(yfit), title='Result from IDL gauss2dfit'

			wset, 4
			result_1 = my2Dgauss(xjunk, yjunk, result_pars)
			plot_image, sigrange(result_1), title='Result from my function.'

			max_x = result_pars[4] - junk_arr_halfsz
			max_y = result_pars[5] - junk_arr_halfsz

			max_tb_indeces = array_indices(junk_array, where(junk_array eq max(junk_array))) ; Stokes I.
			;max_tb_indeces = array_indices(junk_array, where(junk_array eq min(junk_array))) ; Stokes V.
			max_tb_x = max_tb_indeces[0] - junk_arr_halfsz
			max_tb_y = max_tb_indeces[1] - junk_arr_halfsz
			if result_pars[4] eq 1.0 then begin
				source_max_x = x0 + source_x
				source_max_y = y0 + source_y
				;index_max = where(source_section eq max(source_section))
				;max_x = (array_indices(source_section, index_max))[0] 
				;max_y = (array_indices(source_section, index_max))[1]
			endif else begin
				source_max_x = x0 + x0zoom + max_x 
				source_max_y = y0 + y0zoom + max_y 
			endelse
			source_maxTb_x = x0 + x0zoom + max_tb_x 
			source_maxTb_y = y0 + y0zoom + max_tb_y
			

			source_max_x_arcs = (source_max_x - (nrh_hdr.crpix1-0.5))*nrh_hdr.cdelt1	;0.5 for closer to pixel center
			source_max_y_arcs = (source_max_y - (nrh_hdr.crpix2-0.5))*nrh_hdr.cdelt2
			source_maxTb_x_arcs = (source_maxTb_x - (nrh_hdr.crpix1))*nrh_hdr.cdelt1 - 0.25*nrh_hdr.cdelt1
			source_maxTb_y_arcs = (source_maxTb_y - (nrh_hdr.crpix2))*nrh_hdr.cdelt2 - 0.25*nrh_hdr.cdelt2

			; Get weighted average of source position (flux as weights)
			totx = total(data_section>0.0, 2)	; > For Stokes I, < for Stokes V.
			mean_x = total( (findgen(n_elements(totx))+1.0)*totx)/total(totx)
			toty = total(data_section>0.0, 1)	; > For Stokes I, < for Stokes V.
			mean_y = total( (findgen(n_elements(toty))+1.0)*toty)/total(toty)
			src_posx_mean = x0 + mean_x
			src_posy_mean = y0 + mean_y
			src_posx_mean_arc = (src_posx_mean - (nrh_hdr.crpix1))*nrh_hdr.cdelt1 
			src_posy_mean_arc = (src_posy_mean - (nrh_hdr.crpix2))*nrh_hdr.cdelt2

			loadct, 72, /silent
			wset, 3
			plot_map, nrh_map, $
				fov = FOV, $
				center = CENTER, $
				;dmin = 1e6, $
				;dmax = 2.5e8, $
				title='NRH '+string(freq, format='(I03)')+' MHz '+ $
				string( anytim( nrh_time, /yoh, /trun) )+' UT'

			set_line_color
			plots, source_max_x_arcs, source_max_y_arcs, psym=7, color=0, symsize=3, thick=1, /data     ; X  from the fit.
			plots, source_maxTb_x_arcs, source_maxTb_y_arcs, psym=1, color=0, symsize=3, thick=1, /data ; +
			plots, src_posx_mean_arc, src_posy_mean_arc, psym=4, color=0, symsize=3, thick=1, /data     ; diamond
			loadct, 3, /silent
			
			;----------------------------------------------;
			;
			;			 Calculate the flux 
			;
			calculate_flux, source_section, freq*1e6, $
							source_flux, $
							source_Tb

			;print, 'Source Flux at '+anytim(nrh_time, /yoh)+' : '+string(source_flux)+' (sfu)'				
			
			if first_values eq 0 then begin
				xarcs = source_max_x_arcs 		; Position of fit Gaussian max
				yarcs = source_max_y_arcs 		; Position of fit Gaussian max
				x_maxTb = source_maxTb_x_arcs 	; Position of max Tb
				y_maxTb = source_maxTb_y_arcs 	; Position of max Tb
				x_mean = src_posx_mean_arc
				y_mean = src_posx_mean_arc
				gauss_params = result_pars 		; Gaussian fit params
				max_tb = source_Tb  			; Maximum brightness temperature over time
				flux = source_flux 				; Source flux
				poor_src_sizes = poor_src_sz
				times = nrh_time
				first_values=1
			endif else begin
				xarcs = [xarcs, source_max_x_arcs]
				yarcs = [yarcs, source_max_y_arcs]
				x_maxTb = [x_maxTb, source_maxTb_x_arcs]
				y_maxTb = [y_maxTb, source_maxTb_y_arcs]
				x_mean = [x_mean, src_posx_mean_arc]
				y_mean = [y_mean, src_posy_mean_arc]
				gauss_params = [ [gauss_params], [result_pars] ]
				max_tb = [max_tb, source_Tb]
				flux = [flux, source_flux]
				poor_src_sizes = [poor_src_sizes, poor_src_sz]
				times = [times, nrh_time]
			endelse	

		endelse
		
		;progress_percent, img_num, 0, n_elements(nrh_hdrs)-1
	endfor				

	wset, 0
	loadct, 70, /silent
	plot_map, nrh_map, $
		fov = FOV, $
		center = CENTER, $
		;dmin = 1e5, $
		;dmax = 5e8, $
		title='NRH '+string(freq, format='(I03)')+' MHz '+ $
		string( anytim( nrh_time, /yoh) )+' UT'

	colors = findgen(n_elements(xarcs))*(255)/(n_elements(xarcs)-1)
	for i=0, n_elements(xarcs)-1 do plots, xarcs[i], yarcs[i], psym=1, color=colors[i]

	freq_string = string(nrh_hdr.freq, format='(I03)')
	
	xy_arcs_struct = {name:'src_props_'+freq_string, $
						freq:freq, $
						x_max_fit:xarcs, $
						y_max_fit:yarcs, $
						x_maxTb:x_maxTb, $
						y_maxTb:y_maxTb, $
						x_mean:x_mean, $
						y_mean:y_mean, $
						flux_density:flux, $
						Tb:max_Tb, $ 
						gauss_params:gauss_params, $
						poor_src_sizes:poor_src_sizes, $
						times:times}

	if keyword_set(save_props) then save, xy_arcs_struct, filename='~/Data/2014_apr_18/pulsations/nrh_'+freq_string+'_pulse_src1_props_hires_sv.sav', $
			description = 'Stokes I. XY coords in arc seconds. Made using nrh_get_src_props_pulse_isolate.pro'		
		
STOP
END