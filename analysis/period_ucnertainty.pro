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
          yoffset=5

end

pro period_ucnertainty, postscript=postscript

	delta_n_frac = 0.07  ; Fractional uncertainty
	delta_B_frac = interpol([0, 1.0], 100)
	delta_a_frac = 0.1
	delta_T_frac = 0.2

	v=2300.0
	c=130.
	delta_v = sqrt(delta_B_frac^2 + (0.5*delta_n_frac)^2)*v  ; Absolute uncertainty
	delta_c = sqrt( (0.5*delta_T_frac)^2)*c

	delta_P_frac = sqrt(delta_a_frac^2 + (v*delta_v/(v^2+c^2))^2 + (c*delta_c/(v^2+c^2))^2)
	if keyword_set(postscript) then begin
		 setup_ps, '~/PB_uncertainty.eps'
	endif else begin	 
		window, 0, xs=500, ys=500
	endelse	

	plot, delta_B_frac, delta_P_frac, /xs, /ys, $
		xtitle='B fractional uncertainty', $
		ytitle='P fractional uncertainty', $
		charsize=1.5, $
		yr=[0,1], $
		xr=[0,1]

	oplot, [0,1], [0,1], linestyle=1
		
	if keyword_set(postscript) then device, /close
	set_plot, 'x'

END