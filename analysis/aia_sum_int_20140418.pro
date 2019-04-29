pro aia_sum_int_20140418

	
	filters=['131', '094', '335', '171', '193', '211']
	window, 1, xs=600, ys=600, retain=2
	window, 0, xs=600, ys=600, retain=2
	min_exp_t_193 = 1.0	;131
	min_exp_t_211 = 1.5	;94
	min_exp_t_171 = 1.5	;335

	FOV = [5, 5] ;[23.0, 23.0] 
	CENTER = [-100, -200] ;[150, -200]
	t0 = anytim('2014-04-18T12:00:00', /utim)
	t1 = anytim('2014-04-18T13:30:00', /utim)



	for findex=0, n_elements(filters)-1 do begin
		filter=filters[findex]
		files = file_search('~/Data/2014_apr_18/sdo/'+filter+'A/*.fits')
	
	    read_sdo, files, i_a, /nodata, only_tags='exptime,date-obs', /mixed_comp, /noshell
	    files = files[where(i_a.exptime gt 1.5)]
	    i_a = i_a[where(i_a.exptime gt 1.5)]

		filetimes = anytim(i_a.date_d$obs, /utim)

		index = where(filetimes gt t0 and filetimes lt t1)
		files = files[index]

		times = dblarr(n_elements(files))
		flux_data_mean = fltarr(n_elements(files))
		flux_data_sum = flux_data_mean

	  	aia_prep, files[0], -1, hdr, img, /uncomp_delete, /norm
		xcrpix = hdr.naxis1/2.0 + center[0]/hdr.cdelt1
		ycrpix = hdr.naxis2/2.0 + center[1]/hdr.cdelt2

		xfov0 = xcrpix - FOV[0]*60.0/hdr.cdelt1/2.
		xfov1 = xcrpix + FOV[0]*60.0/hdr.cdelt1/2.

		yfov0 = ycrpix - FOV[1]*60.0/hdr.cdelt2/2.
		yfov1 = ycrpix + FOV[1]*60.0/hdr.cdelt2/2.


		for i=0, n_elements(files)-1 do begin

			aia_prep, files[i], -1, hdr, img, /uncomp_delete, /norm

			if i eq 0 then begin
			    index2map, hdr, img, map

			    loadct, 0
				plot_map, map, $
					fov=FOV, $
					center = center, $
					dmin = -10.0, $
					dmax = 1000.0

		        plot_helio, hdr.date_obs, $
		             /over, $
		             gstyle=0, $
		             gthick=1, $  
		             gcolor=0, $
		             grid_spacing=15.0     

		    endif   
		   
	    	;stop
	       	;if hdr.exptime ge 1.0 then begin
				
			;data = map.data
			data_zoom = img[xfov0:xfov1, yfov0:yfov1]/hdr.exptime
			;print, hdr.date_obs
			;plot_image, sigrange(data_zoom)  
			times[i] = anytim(hdr.date_obs, /utim)*1.0D
			flux_data_mean[i] = mean(data_zoom)
			flux_data_sum[i] = total(data_zoom)

			;endif
				

			progress_percent, i, 0, n_elements(files)-1

		 endfor   
		 ;trange = [t0, t1]
		 ;window, 0, xs=600, ys=500
		 ;utplot, times, flux_data/max(flux_data), psym=1, xr=trange, yr=[0.98, 1.01]

		 save, times, flux_data_mean, flux_data_sum, filter, filename='~/Data/2014_apr_18/pulsations/xpoint_intensity/aia_pulse_region_total_int'+filter+'.sav'
	 endfor
stop
END