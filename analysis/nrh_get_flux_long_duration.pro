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

	;loadct, 1, /silent
	;wset, 1
	;plot_image, source_section, title='Flux calculation'

	; Find the max point and mark with a diamond
	index_max = where(source_section eq max(source_section))	; Stokes I.
	;index_max = where(source_section eq min(source_section))	; Stokes V.
	xy_max = array_indices(source_section, index_max)
	;plots, xy_max[0, *], xy_max[1, *], /data, psym=4, color=4
	max_tb = source_section[index_max]

	; Find points above 0.4 of max and mark with cross.
	indices = where(source_section ge max(source_section)*0.5)	; Stokes I.
	;indices = where(source_section le min(source_section)*0.5)	; Stokes V.
	if n_elements(indices) eq 1 then indices=0
	xy_indices = array_indices(source_section, indices)

	;set_line_color
	;plots, xy_indices[0, *], xy_indices[1, *], /data, psym=1, color=3

	total_Tb = TOTAL(source_section[indices])		;summing over specified source are					
	lambda = c / freq
	constant = (2.* k_B * domega) / (lambda^2.)
	flux = constant * total_Tb	; in SFU


END

pro plot_nrh_data, nrh_map, FOV, CENTER, freq, nrh_time, clevels

	plot_map, nrh_map, $
		fov = FOV, $
		center = CENTER, $
		dmin = 1e5, $
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

pro nrh_get_flux_long_duration, save_props=save_props

	; Get the flux of the entire pulsation event, including the initial type III.

	winsize=600

	window, 0, xs=winsize, ys=winsize, retain=2
	window, 1, xs=winsize, ys=winsize, retain=2
	
	folder = '~/data/2014_apr_18/pulsations/nrh_long_dur/' 
	;folder = '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/' 
	cd, folder
	filenames = findfile('*.fts')
	FOV = [15, 15]	; [12, 12]
	CENTER = [-100.0, -300.0]	; [0, -300]
	nlevels=5.0   
	top_percent = 0.50
	first_values=0
	zoom_sz = 16	; 16 for >228 MHz
	source_x = 20	
	source_y = 15	

	tstart = anytim('2014-04-18T12:40:00.000', /utim)	 ;anytim(file2time('20140418_125000'), /utim)	;anytim(file2time('20140418_125546'), /utim)	;anytim(file2time('20140418_125310'), /utim)
	tstop =  anytim('2014-04-18T13:10:00.000', /utim)    ;anytim(file2time('20740418_125440'), /utim)	;anytim(file2time('20140418_125650'), /utim)		;anytim(file2time('20140418_125440'), /utim) 
	t0str = anytim(tstart, /yoh, /time_only)
	t1str = anytim(tstop, /yoh, /time_only)


	for fli=0, 8 do begin
		read_nrh, filenames[fli], $		; CHOOSE FILE
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
		y = 35.0 - 1.5*x > 0.0	; Set this line to use in for loop
		r = sqrt(x^2 + y^2)
		for i=0, n_elements( mask[0,*] )-1 do begin
			for j=0, n_elements(mask[*, 0])-1 do begin
				rindex = sqrt(i^2 + j^2)
				if rindex lt r[i] then mask[i, j]=0.0	; Anything below the line is zeroed.
			endfor
		endfor


		for img_num=0, n_elements(nrh_hdrs)-1 do begin		  
				
			nrh_hdr = nrh_hdrs[img_num]
			nrh_data = nrh_data_cube[*, *, img_num]
			index2map, nrh_hdr, nrh_data, nrh_map  
			nrh_time = nrh_hdr.date_obs
					
			;------------------------------------;
			;		  Plot img arcsec
			;loadct, 3, /silent
			;wset, 0
			;max_val = max( (nrh_data), /nan) 		
			;clevels = (dindgen(nlevels)*(max_val - max_val*top_percent)/(nlevels-1.0)) + max_val*top_percent  
			;plot_nrh_data, nrh_map, FOV, CENTER, freq, nrh_time, clevels
			data_section = nrh_data[x0:x1, y0:y1]
			data_section = mask*data_section

			;------------------------------------------------------;
			;  Extract src plus a small section around that source
			x0zoom = (source_x-zoom_sz > 0 < ((size(data_section))[1]-1) )
			x1zoom = (source_x+zoom_sz > 0 < ((size(data_section))[1]-1) )
			y0zoom = (source_y-zoom_sz > 0 < ((size(data_section))[2]-1) )
			y1zoom = (source_y+zoom_sz > 0 < ((size(data_section))[2]-1) )
			source_section = data_section[x0zoom:x1zoom, y0zoom:y1zoom] 

			source_section[where(source_section lt 1e6)]=0.0
			source_section[ 21:n_elements(source_section[*,0])-1, * ] = 0.0;min(source_section)	; Try and zero the second source.

				
			;----------------------------------------------;
			;
			;			 Calculate the flux 
			;
			calculate_flux, source_section, freq*1e6, $
							source_flux, $
							source_Tb

			;print, 'Source Flux at '+anytim(nrh_time, /yoh)+' : '+string(source_flux)+' (sfu)'				
			
			if first_values eq 0 then begin
				flux = source_flux 				; Source flux
				times = nrh_time
				first_values=1
			endif else begin
				flux = [flux, source_flux]
				times = [times, nrh_time]
			endelse
		
			
			progress_percent, img_num, 0, n_elements(nrh_hdrs)-1
		endfor				

		freq_string = string(nrh_hdr.freq, format='(I03)')
		
		flux_struct = {name:'src_flux_'+freq_string, $
							freq:freq, $
							flux_density:flux, $, $
							times:times}

		if keyword_set(save_props) then save, flux_struct, filename='~/Data/2014_apr_18/pulsations/long_dur_flux/nrh_'+freq_string+'_flux_long_duration.sav', $
				description = 'Stokes I. Made using nrh_get_flux_long_duration.pro'		
		first_values=0
	endfor			
		
STOP
END