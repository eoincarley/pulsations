pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.1
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=6, $
          ysize=6, $
          /encapsulate, $
          yoffset=5, $
          bits_per_pixel = 16

end

function hydrostat_model, distance, parms
	
	; n0 in cm^-3
	; temperature in K
	; dist in Mm

	n0 = (10^parms[0])*1e6  			; m^-3
    k = 1.38e-23    			; J/K
    T = parms[1]      			; K
    m = 1.66e-27    			; kg (amu)
    gearth=9.88     			; m/s/s
    gsun = 27.94*gearth     	; m/s/s
    H = (k*T)/(m*gsun)/1e6      ; Mm
    den_model = n0*exp(-1.0*distance/H)   	; m^-3
    den_model = den_model/1e6           ; cm^-3	

	return, alog10(den_model)
end

function calc_period, Temp, n_i, radius
	
	mp = 1.67e-24				; g
	gam = 5./3.  				; Adiabatic index for monotonic gas
	kb = 1.38e-16 				; erg/K (Boltzmann constant cgs units)
	sound_speed = sqrt(gam*kb*Temp/mp) 
	B = 50 						; G   (From the NLFFF) 
	va = B/sqrt(4.0*!pi*n_i*mp) ; cm/s
	vfast = sqrt(va^2.0 + sound_speed^2)
	P = radius/vfast				; s
	print, 'Sausage mode period <='+string(P)+' s'
	return, P
END

pro plot_figure5bd, postscript=postscript

	; Code to plot results of loop_density.pro

	; Also plots Figure 5b and d of pulsations paper

	restore, '~/idl/pulsations/DEM/loop_props.sav', /verbose				; from calc_loop_props.pro
	restore, '~/idl/pulsations/DEM/total_em_20140418_1250.sav', /verbose  	; from calc_loop_props.pro

	if keyword_set(postscript) then begin
		setup_ps, '~/Desktop/loop_total_EM.eps'
	endif else begin	
		window, 0, xs=400, ys=400
		window, 1, xs=400, ys=400
		wset, 0
	endelse
		
	;wset, 0
	loop_em = smooth(loop_em, 3)
	max_em = 2e28
	min_em = 1.8e27
	set_line_color
	plot, [0, 70], [0, 70], /nodata, color=0, position = [0.1, 0.1, 0.9, 0.85], /normal, /xs, /ys, $
		xtitle='X (Mm)', ytitle='Y (Mm)'


	cgColorbar, Range=[min_em, max_em], $
       title='Emission measure (cm!U-5!N)', $
       position = [0.1, 0.86, 0.9, 0.875 ], charsize=1.3, /top, color=0	

    loadct, 70
	plot_image, loop_em > min_em <max_em, charsize=1.2, $
		position = [0.1, 0.1, 0.9, 0.85], /normal, xtickformat='(A1)', ytickformat='(A1)', /noerase

	cgColorbar, Range=[min_em, max_em], $
       title='  ', $
       position = [0.1, 0.86, 0.9, 0.875 ], charsize=1.3, /top, color=0, xtickformat='(A1)'



    profs = loop_props.em_profiles
    density = loop_props.loop_density	; These are from max EM in the loop. Also calculated densities from mean EM in the loop, see below.
    xlins = loop_props.xlins
    ylins = loop_props.ylins
    loop_bounds = loop_props.loop_bounds
    save, loop_bounds, filename='/Users/eoincarley/python/NLFFF/loop_bounds.sav'


	set_line_color
	start_index=2
	for i=start_index, n_elements(density)-5 do begin
		xlin = xlins[*,*,i]
		ylin = ylins[*,*,i]
		radial = sqrt(xlin^2.0 + ylin^2.0)

		plots, xlin>0.0, ylin>0.0, /data, color=4, thick=3.5
		plots, [135, 146], [10, 10], color=1, /data, thick=3, linestyle=0
		if i eq start_index then xyouts, 135, 12, '5 Mm', /data, charsize=1.5, color=1

	   	;----------------------------------------;
	   	;
	   	;	  Plot the points on the map
	   	;
	   	inner_x = loop_bounds[0,i]
	   	outer_x = loop_bounds[1,i]
	   	inner_y = loop_bounds[2,i]
	   	outer_y = loop_bounds[3,i]
	 

	   	xmid = inner_x + (outer_x - inner_x)/2.0 
	   	ymid = inner_y + (outer_y - inner_y)/2.0

	   	plots, inner_x, inner_y, psym=1, thick=10, color=0
	   	plots, outer_x, outer_y, psym=1, thick=10, color=0	

	   	plots, inner_x, inner_y, psym=1, thick=3, color=4
	   	plots, outer_x, outer_y, psym=1, thick=3, color=4	

	   	plotsym, 0, /fill
	   	;plots, xmid, ymid, psym=8, thick=5, color=0
	   	plots, xmid, ymid, psym=8, thick=3, color=5, symsize=0.7

	   	if i eq start_index then begin
	   		distancex = xmid
	   		distancey = ymid
	   		distance=0
	    endif else begin
	    	deltax = distancex-xmid
	    	deltay = distancey-ymid
	    	delta = sqrt(deltax^2 + deltay^2)*0.6*727/1e3
	    	distance = [distance, distance[n_elements(distance)-1]+delta]
	    	distancex = xmid
	    	distancey = ymid
	    endelse

 		;---------------------------------------;
	    ;
	    ;	  Get physical loop params
	    ;

	    loop_width = sqrt( (outer_x-inner_x)^2.0 + (outer_y-inner_y)^2.0 )*0.6*727/1e3 ;Mm
		print, 'Width: '+string(loop_width)+' Mm'
		loop_width = loop_width*1e8 ; cm
	   	radial = sqrt( xlin[0:50]^2.0 +ylin[0:50]^2.0)
	   	inner_point = sqrt(inner_x^2+inner_y^2.0)
	   	outer_point = sqrt(outer_x^2+outer_y^2.0)
	    indices = where(radial lt inner_point and radial gt outer_point)	; These indices are the points within the loop inner and outer bounds.
	    ;wset, 1
	    ;plot, profs[*, i]
	    ;oplot, indices, profs[indices, i], color=4
		em_mean = mean(profs[indices, i])
	    loop_ne = sqrt(em_mean/loop_width)
	    print, 'Loop density: '+string(loop_ne)+' cm^-3'
	    if i eq start_index then begin
	    	density=loop_ne 
	    	loop_widths = loop_width
	    endif else begin
	    	density = [density, loop_ne]
	    	loop_widths = [loop_widths, loop_width]
	    endelse	

	endfor   
	if keyword_set(postscript) then begin
		device, /close
		set_plot, 'x'
	endif

	if keyword_set(postscript) then setup_ps, '~/desktop/loop_ne_width.eps' else wset, 1

	;---------------------------------------;
	;
	;	  Plot density along the loop
	; 
	;distance = distance[2:n_elements(distance)-2]
	;density = density[2:n_elements(distance)-2]
	set_line_color
	plotsym, 0, /fill
	plot, distance, density, $
		color=0, $
		xtitle='Distance along loop (Mm)', $
		ytitle=' ', $
		yticks=3, $
		yr=[1.5e9, 3e9], $
		ytickformat='(A1)', $
		yticklen='-1e-04', $
		/xs, $
		/ys, $
		psym=8, $
		position=[0.2, 0.2, 0.9, 0.9]
		;/ylog
		
	axis, yaxis=0, yrange=[1.5e9, 3e9], yticks=3, ytitle='Electron density (cm!U-3!N)', color=5, /ys, $
		ytickname=['1.5', '2.0', '2.5', '3.0']	

	frac_error=0.07
	xerr = replicate(0, n_elements(distance))
	yerr = density*frac_error ;replicate(1e8, n_elements(distance))
	oploterr, distance, density, xerr, yerr, ERRCOLOR=5, color=5, /nohat, thick=4
	oplot, distance, density, color=5
	oplot, distance, density, color=5, psym=8, thick=4

	xyouts, 0.2, 0.91, 'x10!U9!N', color=5, /normal	

	;------------------------------------------------;
	;
	;	  Overplot hydrostatic equilibrium models
	; 
	; Leg 1
	loop1i=12
	leg1_dens = alog10(density[0:loop1i])
	leg1_dist = distance[0:loop1i]	
	;plot, leg1_dist, leg1_dens, /xs, /ys
    start = [alog10(2.6e9), 1.5e6]
    errs = leg1_dens*frac_error ;replicate(1.0, n_elements(leg1_dens))
    pi = replicate({value:0.D}, 2)
    pi[*].value = start
    p1 = mpfitfun('hydrostat_model', leg1_dist, leg1_dens, errs, parinfo=pi, perror=perror1, bestnorm=bestnorm, dof=dof) 
    PCERROR1 = perror1 * SQRT(BESTNORM / DOF)

    dist1 = interpol([distance[0], 20], 100)
    density1 = hydrostat_model(dist1, p1)
    oplot, dist1, 10^density1, color=0, thick=8
    oplot, dist1, 10^density1, color=7, thick=6


    ; Leg 2
    leg2_dens = alog10(density[where(distance gt 16)])
	leg2_dist = distance[where(distance gt 16)]
	leg2_dist = leg2_dist[n_elements(leg2_dist)-1] - leg2_dist

	start = [alog10(2.6e9), 1.5e6]
	pi[*].value = start
	errs = leg2_dens*frac_error ;replicate(1.0, n_elements(leg2_dens))
	p2 = mpfitfun('hydrostat_model', leg2_dist, leg2_dens, errs, parinfo=pi, perror=perror2, bestnorm=bestnorm, dof=dof) 
	PCERROR2 = perror2 * SQRT(BESTNORM / DOF)


	dist2 = interpol([0, 30], 100)
	dist2 = dist2
    density2 = hydrostat_model(dist2, p2)
    dist2 = distance[n_elements(distance)-1] -dist2
    density2 = 10^density2
    oplot, dist2, density2, color=0, thick=8;, /xs, /ys
    oplot, dist2, density2, color=10, thick=5;, /xs, /ys


    ;xyouts, 0.26, 0.3, 'T~10!U5.9!N K', color=7, /normal

    ;------------------------------------------------;
	;
	;	  			Overplot loop width
	; 
   	axis, yaxis=1, yrange=[5,12], ytitle='Loop width (Mm)', color=6, /ys
	plot, distance, loop_widths/1e8, $
		color=1, $
		ytickformat='(A1)', $
		xtickformat='(A1)', $
		yr=[4, 15], $
		/ys, $	
		/xs, $
		/noerase, $
		psym=8, $
		position=[0.2, 0.2, 0.9, 0.9]

	oploterr, distance, (loop_widths/1e8), xerr, (loop_widths/1e8)*0.1, ERRCOLOR=6, /nohat, color=6, linestyle=1, thick=4
	oplot, distance, loop_widths/1e8, color=6, linestyle=1, thick=4
	oplot, distance, loop_widths/1e8, color=6, psym=8

	if keyword_set(postscript) then begin
		device, /close	
		set_plot, 'x'
	endif
	
	;---------------------------------------------------------------;
	;
	;	  Calculate the sausage mode period this loop would carry.
	; 
	; Mean
	Temp = mean([p1[1], p2[1]])	; K
   	n_i = mean(density)			; cm^-3
   	radius = mean(loop_width)/2.0		; cm
	period = calc_period(Temp, n_i, radius)

	; Minimum
	Temp = max([p1[1], p2[1]])	; K
   	n_i = min(density)			; cm^-3
   	radius = min(loop_width)/2.0		; cm
	period = calc_period(Temp, n_i, radius)

	; Maximum
	Temp = min([p1[1], p2[1]])	; K
   	n_i = max(density)			; cm^-3
   	radius = max(loop_width)/2.0		; cm
	period = calc_period(Temp, n_i, radius)
	

stop

END