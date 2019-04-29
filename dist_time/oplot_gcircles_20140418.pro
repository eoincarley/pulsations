pro oplot_gcircles_20140418, hdr

	npoints=1000.0
	gcircles_file = '~/Data/2014_apr_18/sdo/dist_time/great_circles/xy_gcircle_arcs_20140418_south.sav'
	restore, gcircles_file, /verbose
	arc_numbers=(tag_names(xy_pixel_profs))[where(strmid(tag_names( xy_pixel_profs), 0, 5) eq 'XYPIX')]


	set_line_color	
	for q=1, n_elements(arc_numbers)-1 do begin
		arc_number = arc_numbers[q]
		xypos = XY_PIXEL_PROFS.(where(tag_names(XY_PIXEL_PROFS) eq arc_number))
		azim = xy_pixel_profs.(where(tag_names(XY_PIXEL_PROFS) eq arc_number)+1)
		azim = azim[0:n_elements(azim)-1]
		pixx = xypos[0, 0:n_elements(azim)-1]
		pixy = xypos[1, 0:n_elements(azim)-1]
		lindMm = (azim - azim[0])*!dtor*695.0
		xlin = (pixx - hdr.naxis1/2.)*hdr.cdelt1
		ylin = (pixy - hdr.naxis2/2.)*hdr.cdelt2

		ind100Mm = closest(lindMm, 100.)
		ind200Mm = closest(lindMm, 200.)
		ind300Mm = closest(lindMm, 300.)
		ind400Mm = closest(lindMm, 400.)

		xlin = xlin[where(xlin gt -750)]
		ylin = ylin[where(xlin gt -750)]

		;xlin = xlin[where(ylin gt -850)]
		;ylin = ylin[where(ylin gt -850)]

		plotsym, 0, /fill
		plots, smooth(xlin,5), smooth(ylin,5), /data, color=6, thick=3.5
		;plots, xlin[ind100Mm], ylin[ind100Mm], /data, color=3, thick=4.5, psym=8, symsize=2
		;plots, xlin[ind200Mm], ylin[ind200Mm], /data, color=3, thick=4.5, psym=8, symsize=2
		plots, xlin[ind300Mm], ylin[ind300Mm], /data, color=3, thick=3.5, psym=8, symsize=1
		plots, xlin[ind400Mm], ylin[ind400Mm], /data, color=3, thick=3.5, psym=8, symsize=1
		if q eq 1 then begin
			delta=25
			xyouts, xlin[ind300Mm]+delta, ylin[ind300Mm]-delta, '300 Mm', /data, color=3
			xyouts, xlin[ind400Mm]+delta, ylin[ind400Mm]-delta, '400 Mm', /data, color=3
		endif	

	endfor			   


END