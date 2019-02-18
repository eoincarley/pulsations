pro setup_ps, name
  
  set_plot,'ps'
  !p.font=0
  !p.charsize=1.0
  !p.thick=4
  device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=6, $
          ysize=6, $
          /encapsulate, $
          yoffset=5, $
	  bits_per_pixel=32

end

pro plot_supp_figXa, postscript=postscript

	
	filters=['131', '094', '335', '171', '193', '211']
	min_exp_t_193 = 1.0	;131
	min_exp_t_211 = 1.5	;94
	min_exp_t_171 = 1.5	;335

	FOV = [5, 5] ;[23.0, 23.0] 
	CENTER = [-100, -200] ;[150, -200]
	t0 = anytim('2014-04-18T12:00:00', /utim)
	t1 = anytim('2014-04-18T13:30:00', /utim)


	filter=filters[3]
	files = file_search('~/Data/2014_apr_18/sdo/'+filter+'A/*.fits')
	
	read_sdo, files, i_a, /nodata, only_tags='exptime,date-obs', /mixed_comp, /noshell
	files = files[where(i_a.exptime gt 1.5)]
	i_a = i_a[where(i_a.exptime gt 1.5)]

	filetimes = anytim(i_a.date_d$obs, /utim)

	index = where(filetimes gt t0 and filetimes lt t1)
	files = files[index]

	aia_prep, files[0], -1, hdr, img, /uncomp_delete, /norm

	index2map, hdr, img, map
	
	if keyword_set(postscript) then begin
		setup_ps, '~/Dropbox/DFigures/supp_figXa.eps'
	endif else begin
		window, 1, xs=600, ys=600, retain=2
	endelse
		
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
		   
	if keyword_set(postscript) then device, /close
	set_plot, 'x'
stop
END
