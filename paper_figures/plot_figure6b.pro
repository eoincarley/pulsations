pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=0.9
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=10, $ ; 6.5
          ysize=4.5, $ ; 2.8
          /encapsulate, $
          yoffset=5, $
          bits_per_pixel = 16

end


pro plot_figure6b, postscript=postscript

	restore, '~/Data/2014_apr_18/radio/orfees/pulse_flux_spectra.sav'
	set_line_color


	;***********************************;
	;	 Plot peak intensity spectrum
	if keyword_set(postscript) then begin
		setup_ps, '~/Data/2014_apr_18/radio/orfees/pulsation_flux_spec_time.eps'
	endif else begin
		loadct, 0
		window, 0, xs=1200, ys=400
	endelse	
	
	time_start = anytim('2014-04-18T12:56:00', /utim)
	time_stop = anytim('2014-04-18T12:57:30', /utim)
	set_line_color
	utplot, time, pos_index, /xs, /ys, yr=[0, 26], $
		xr =[time_start, time_stop], $
		color=6, xtitle='Time (UT)', ytitle='Spectral index', thick=3, $
		pos = [0.1, 0.1, 0.9, 0.9]

	outplot, time, abs(neg_index), color=5, thick=3


	loadct, 0
	outplot, time, 15*max_flux/max(max_flux), color=170, thick=6

	if keyword_set(postscript) then device, /close
	set_plot, 'x'

END
