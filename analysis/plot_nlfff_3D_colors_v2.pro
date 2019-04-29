pro setup_ps, name, xsize, ysize

    set_plot,'ps'
    !p.font=0
    !p.charsize=1.2
    device, filename = name, $
        ;/decomposed, $
        /color, $
        /helvetica, $
        /inches, $
        xsize=8.0, $
        ysize=8.0, $
        /encapsulate, $
        bits_per_pixel=32
end

pro plot_plane, xrange, yrange, zrange
	
	xplane = interpol([xrange[0], xrange[1]], 100)
	yplane = interpol([yrange[0], yrange[1]], 100)
	zplane = interpol([zrange[0], zrange[1]], 100)

	loadct, 0, /silent
	plots, xplane, $
		   yplane, $
		   zplane, $
		   col=20., $
		   thick=1.0, $
		   /t3d

end

pro draw_box, color, bxthick
	
	set_line_color	
	box_size = 19.
	x0 = 95
	y0 = 160
	z0 = 0.0
	; Bottom
	plots, [x0, x0], [y0, y0+box_size], [z0,z0], color=color, thick=bxthick, linestyle=2, /t3d
	plots, [x0, x0+box_size], [y0, y0], [z0,z0], color=color, thick=bxthick, linestyle=2, /t3d
	plots, [x0, x0+box_size], [y0+box_size, y0+box_size], [z0,z0], color=color, thick=bxthick, linestyle=2, /t3d
	plots, [x0+box_size, x0+box_size], [y0, y0+box_size], [z0,z0], color=color, thick=bxthick, linestyle=2, /t3d

	; top
	plots, [x0, x0], [y0, y0+box_size], [z0,z0]+box_size, color=color, thick=bxthick, linestyle=2, /t3d
	plots, [x0, x0+box_size], [y0, y0], [z0,z0]+box_size, color=color, thick=bxthick, linestyle=2, /t3d
	plots, [x0, x0+box_size], [y0+box_size, y0+box_size], [z0,z0]+box_size, color=color, thick=bxthick, linestyle=2, /t3d
	plots, [x0+box_size, x0+box_size], [y0, y0+box_size], [z0,z0]+box_size, color=color, thick=bxthick, linestyle=2, /t3d


	; top
	plots, [x0, x0], [y0, y0], [z0,z0+box_size], color=color, thick=bxthick, linestyle=2, /t3d
	plots, [x0+box_size, x0+box_size], [y0, y0], [z0,z0+box_size], color=color, thick=bxthick, linestyle=2, /t3d
	plots, [x0, x0], [y0+box_size, y0+box_size], [z0,z0+box_size], color=color, thick=bxthick, linestyle=2, /t3d
	plots, [x0+box_size, x0+box_size], [y0+box_size, y0+box_size], [z0,z0+box_size], color=color, thick=bxthick, linestyle=2, /t3d



end

pro oplot_radio_src_points, freq, color

    restore, '~/Data/2014_apr_18/pulsations/nrh_'+freq+'_pulse_src1_props_hires_si.sav', /verb  
    t0_points = anytim('2014-04-18T12:55:20', /utim)
    times = anytim(xy_arcs_struct.times, /utim)
    x0 = (0.0 - 8.25*60./2.0)
	y0 = (-200.0 - 8.25*60.0/2.0)
    xarcs = abs(x0 - xy_arcs_struct.x_max_fit)*0.727 ; Mm
    yarcs = abs(y0 - xy_arcs_struct.y_max_fit)*0.727
    zpos = xarcs
    frequency = float(freq)*1e6
    altitude = (density_to_radius(freq_to_dens(frequency), model='newkirk')-1.0)*695.0 ; Mm
    zpos[*]=altitude



    for i=0, n_elements(xarcs)-1 do begin ; 32 arbitraty, just plots first 4 data points.
      if times[i] gt t0_points then begin
        ;plots, xarcs[i], yarcs[i], psym=8, color=0, symsize=1.1, thick=2
        ;plots, xarcs[i], yarcs[i], psym=8, color=1, symsize=1.0, thick=2
        if xarcs[i] lt 110.0 then begin

        	loadct, 0.0, /silent
        	plots, [xarcs[i], xarcs[i]], [yarcs[i], yarcs[i]], [zpos[i], 0.0], linestyle=2, color=0, thick=3, /t3d
        	plots, [xarcs[i], xarcs[i]], [yarcs[i], 200.], [zpos[i], zpos[i]], linestyle=2, color=0,  thick=3,/t3d
        	plots, [xarcs[i], 150], [yarcs[i], yarcs[i]], [zpos[i], zpos[i]], linestyle=2, color=0, thick=3, /t3d

        	plot_sphere_symbol, xarcs[i], yarcs[i], zpos[i], color, [150, 255]
        	print, xarcs[i], yarcs[i], zpos[i]
        endif	
        	;plots, xarcs[i], yarcs[i], zpos[i], psym=8, color=colors[i], symsize=1.0, thick=1, /t3d
      endif  
    endfor  
    
    ;set_line_color
    ;xarcs = xarcs[where(times gt t0_points)]
    ;yarcs = yarcs[where(times gt t0_points)]
    ;plots, mean(xarcs), mean(yarcs), zpos, color=0, psym=8, symsize=2, thick=10, /t3d
    ;plots, mean(xarcs), mean(yarcs), zpos, color=100, psym=8, symsize=1, thick=5, /t3d

END

pro plot_nlfff_3D_colors_v2, postscript=postscript

	; Obsolete code. This is now done in Python.

	; Get the loop width in AIA at the radio source position
	; v2 attempting to overplot the NLFFF.



	loadct, 0
	!p.charsize=1.5
	winsz=800
	AU = 1.49e11	; meters
	aia_waves = ['094A', '131A', '335A']
	angle = 0.0
	npoints = 4000
	radius = 240	;arcsec
	x1 = -150.0
	y1 = -300.0
	FOV = [5.0, 5.0]
	CENTER = [-100.0, -250.0]

	;-------------------------------------------------;
	;
	;		  Choose files unaffected by AEC
	;
	folder = '~/Data/2014_Apr_18/sdo/171A/'
	aia_files = findfile(folder+'aia*.fits')
	mreadfits_header, aia_files, ind, only_tags='exptime'
	f = aia_files[where(ind.exptime gt 1.)]

	;window, 0, xs=winsz, ys=winsz, retain = 2, xpos=1900, ypos=1000
	if keyword_set(postscript) then begin
		setup_ps, '~/Desktop/field_lines_3D.eps', winsz, winsz
		thick=10
		col=0
	endif else begin
		window, 1, xs=winsz, ys=winsz, retain = 2;, xpos=1900, ypos=1000
		;window, 1, xs=500, ys=500;, xpos=1900, ypos=100
		thick=2
		col=1
	endelse	


	;----------------------------------------------------;
	;
	;		Define lines over which to interpolate
	;
	read_sdo, f[0], hdr, aia_img

    restore, '~/data/2014_apr_18/pulsations/nlfff_lines_bxbybz.sav'
    ; Note these are in pixel units, built in an 8.25 arcmin FOV at [0, -200]. Have to get the x and y 0 pix of window,
    ; then add the line coord pix, then covert to xarcs and yarcs.
    x0 = (0.0 - 8.25*60./2.0)/hdr.cdelt1 + hdr.crpix1
    y0 = (-200.0 - 8.25*60.0/2.0)/hdr.cdelt2 + hdr.crpix2
	

		;----------------------------------------------------;
		;--------------Set up 3D environment-----------------;
		;----------------------------------------------------;
		loadct, 0
		;wset, 1
		box_sz = 250.  ; Mm
	 	x_range = [55.0, 140.0] ;[0.1, 1.5]
	  	y_range = [100.0, 200.0] ;[0.1, 1.2]
	   	z_range = [0.0, 80.]

		surface, dist(5), /nodata, /save, xrange=x_range, yrange=y_range, $
			zrange=z_range, ax=20, az=20.,  $
			xtit=' ', ytitle='  ', ztitle ='Altitude (Mm)', /xs, /ys, /zs, $
			position = [0.15, 0.15, 0.8, 0.8], /normal, $
			ZTICKLEN=1,  ZGRIDSTYLE=5, xtickformat='(A1)', ytickformat='(A1)'

		alt = indgen(8)*20.	
		for linind = 0, 4 do plots, [x_range[1], x_range[1]], [y_range[0], y_range[1]], [alt[linind], alt[linind]], linestyle=5, /t3d		


		;----------------------------------------------------;
		;--------------Plot the projections-----------------;
		;----------------------------------------------------;

		loadct, 0.0, /silent
	    for i = 0, n_elements(xlines)-10 do begin
	    
	    	xlin = reverse(xlines[i])*0.727    ; Mm
	    	ylin = reverse(ylines[i])*0.727 
	    	zlin = reverse(zlines[i])*0.727 
	    	xlin = xlin[where(xlin gt x_range[0] and xlin lt x_range[1] and ylin gt y_range[0] and ylin lt y_range[1] and zlin lt z_range[1])]
			ylin = ylin[where(xlin gt x_range[0] and xlin lt x_range[1] and ylin gt y_range[0] and ylin lt y_range[1] and zlin lt z_range[1])]
			zlin = zlin[where(xlin gt x_range[0] and xlin lt x_range[1] and ylin gt y_range[0] and ylin lt y_range[1] and zlin lt z_range[1])]
	    	zplane = zlin
	    	yplane = zlin
	    	xplane = zlin
	    	zplane[*] = 0.0
	    	yplane[*] = y_range[1]
	    	xplane[*] = x_range[1]

			plots, xlin, ylin, zplane, col=200., linestyle=0, thick=3, /t3d
			plots, xlin, yplane, zlin, col=200., linestyle=0, thick=3, /t3d
			plots, xplane, ylin, zlin, col=200., linestyle=0, thick=3, /t3d

		endfor	


		draw_box, 0, 5
		draw_box, 10, 4
		;----------------------------------------------------;
		;--------------Plot lines with colors----------------;
		;----------------------------------------------------;
		oplot_radio_src_points, '228', 56 ; Red

		ncols = 1000.
	    colors = findgen(ncols)*(255)/999.
	    maxb = 3.0
	    minb = 1e-2
		bfields = (findgen(ncols)*(maxb + minb)/(ncols-1) - minb)			

		for i = n_elements(xlines)-10, 0, -1 do begin
	    
	    	bx_lin = reverse(bx[i])	
			by_lin = reverse(by[i])	
			bz_lin = reverse(bz[i])		
			field_strength = sqrt(bx_lin^2 + by_lin^2 + bz_lin^2)    
			field_strength = alog10(field_strength)	; log values
	    	xlin = reverse(xlines[i])*0.727    ; Mm
	    	ylin = reverse(ylines[i])*0.727 
	    	zlin = reverse(zlines[i])*0.727 


	    	xlin = xlin[where(xlin gt x_range[0] and xlin lt x_range[1] and ylin gt y_range[0] and ylin lt y_range[1] and zlin lt z_range[1])]
			ylin = ylin[where(xlin gt x_range[0] and xlin lt x_range[1] and ylin gt y_range[0] and ylin lt y_range[1] and zlin lt z_range[1])]
			zlin = zlin[where(xlin gt x_range[0] and xlin lt x_range[1] and ylin gt y_range[0] and ylin lt y_range[1] and zlin lt z_range[1])]
			loadct, 0, /silent
			plots, xlin, ylin, zlin, col=col, linestyle=0, thick=thick+4, /t3d

	    	zeros = zlin
	    	zeros[*] = 0.0
			cols = interpol(colors, bfields, field_strength) 

			for jj=1, n_elements(xlin)-1 do begin 
	        	
 					loadct, 33, /silent
 					gamma_ct, 0.6
					plots, [xlin[jj], xlin[jj-1]], $
						   [ylin[jj], ylin[jj-1]], $
						   [zlin[jj], zlin[jj-1]], $
						   col=cols[jj], $
						   linestyle=0, $
						   thick=thick, $
						   /t3d
	      
			endfor  

	    endfor    

	    loadct, 33, /silent
	    gamma_ct, 0.6
	    cgcolorbar, range = 10^[minb, maxb], $
    		/ylog, $
			/right, $
			/vertical, $
			color=10, $
			pos = [0.88, 0.1, 0.89, 0.85], $
			title = 'Magnetic Field Strength (G)'

		
    if keyword_set(postscript) then device, /close
    set_plot, 'x'
	

STOP
END