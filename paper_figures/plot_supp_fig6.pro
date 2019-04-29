pro setup_ps, name
  
  set_plot,'ps'
  !p.font=0
  !p.charsize=1.0
  !p.thick=4
  device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=14, $
          ysize=7, $
          /encapsulate, $
          yoffset=5

end

pro plot_supp_fig6

	; A non-linear limit cycle predicts that the Flux I ~ period t^2. This code attempts to 
	; find (or not) such a relationship.
	loadct, 0
	;!p.background=50
	;window, 0, xs=1200, ys=600
	;!p.charsize=1.2

	restore, '~/Data/2014_apr_18/radio/pulse_props.sav', /verb ; made using limit_cycle_analysis_orfees.pro
	times = pulse_props.times
	flux = pulse_props.flux
	trough_times = pulse_props.trough_times
	peak_times = pulse_props.peak_times
	peaks = pulse_props.peaks
	troughs = pulse_props.troughs
	times_fine = pulse_props.times_fine
	flux_fine = pulse_props.flux_fine
	flux_deriv = pulse_props.flux_deriv
	time_zeros = pulse_props.time_zeros
	zeros = pulse_props.zeros
	pulse_period = pulse_props.pulse_period
	pulse_flux = pulse_props.pulse_flux

	setup_ps, '~/Desktop/pulse_properties.eps'

	loadct, 0
	plot, times, flux, $
		/xs, /ys, $
		ytitle='Flux (SFU)', $
		xtickformat='(A1)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 0.01, $
  		xtitle = ' ', $
  		yr=[300, 2000], $
  		xr=xrange, $
		/normal, $
		/noerase, $
		position=[0.049, 0.5, 0.565, 0.79], color=50

	set_line_color
	oplot, trough_times, troughs, psym=1, color=0, thick=5
	oplot, trough_times, troughs, psym=1, color=4
	oplot, peak_times, peaks, psym=1, color=0, thick=5	
	oplot, peak_times, peaks, psym=1, color=10	
	
	;------------------------------------------;
	;
	;			 First derivative
	;
	loadct, 0
	plot, times_fine, flux_deriv, $
		/xs, $
		/ys, $
		ytitle='Flux (SFU)', $
		;xtickformat='(A1)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 0.01, $
  		xtitle = 'Time (s) after 12:54:55 UT', $
  		;yr=[10, 220], $
  		xr=xrange, $
		/normal, $
		/noerase, $
		position=[0.049, 0.2, 0.565, 0.49], $
		color=50	

	set_line_color
	oplot, time_zeros, zeros, psym=1, color=6		

	;------------------------------------------;
	;
	;	   Plot pulse period against flux
	;
	pulse_period = pulse_period[where(pulse_flux gt 10.0)]
	pulse_flux = pulse_flux[where(pulse_flux gt 10.0)]
	plotsym, 0, /fill
	;window, 1, xs=500, ys=500
	plot, pulse_period, pulse_flux, $
		xtitle='Pulse period (s)', $
		ytitle='Pulse amplitude (SFU)', $
		;ytickformat='(A1)', $
		psym=8, $
		;/ylog, $
		/ys, $
		yr=[1e1, 8e2], $
		xr=[0.5, 3.5], $
		/xs, $
		color=0, $
		position=[0.61, 0.2, 0.91, 0.79], $
		/noerase
	oplot, pulse_period, pulse_flux, color=5, psym=8

	pcc = correlate(pulse_period, pulse_flux)
	print, 'Pearson CC: '+string(pcc)

	plothist, pulse_period, bin=0.3, pos=[0.61, 0.79, 0.91, 0.95 ], /noerase, color=0, xtickformat='(A1)', $
		ytitle='No. of pulses'

	;window, 1, xs=500, ys=500
	plothist, pulse_flux, bin=100, /rotate, yr=[10, 8e2], xr=[0,20], xtitle='No. of pulses', ytickformat='(A1)', $
		pos=[0.91, 0.2, 0.99, 0.79], /ys, /noerase, color=0, ytitle=' ', xtickv=[5, 10, 15, 20], $
		xtickname=['5', '10', '15', '20'], xticks=3, /xs


	xyouts, 0.62, 0.75, 'Pearson CC: '+string(pcc, format='(f6.2)'), /normal	

	;axis, yaxis=1, yr=[10, 8e2], ytitle=' ', color=1, /ys

	
	device, /close
	set_plot, 'x'

	;----------------------------------------------------;
	;
	;			Limit cycle expectation
	;
	window, 1, xs=500, ys=500
	plot, pulse_period, pulse_flux, $
		xtitle='Pulse period (s)', $
		ytitle='Pulse amplitude (SFU)', $
		;ytickformat='(A1)', $
		psym=8, $
		;/ylog, $
		/ys, $
		yr=[1e1, 8e2], $
		xr=[0.5, 3.5], $
		/xs, $
		color=0, $
		/noerase
	oplot, pulse_period, pulse_flux, color=5, psym=8
	stop
	yerr = replicate(0.1, n_elements(pulse_flux))
	start = [0.1, 0.1]		
	fit = 'p[0]*x^2.0 + p[1]'	
	p = mpfitexpr(fit, pulse_period, pulse_flux, $
					yerr, $
					yfit=yfit, $
					weights=weights, $
					start, $
					perror = perror, $
					bestnorm = bestnorm, $
					dof=dof)	

	;oplot, yfit
	chisqr_prob = (1.0-chisqr_pdf(bestnorm, dof))*100.0
	box_message, str2arr('Probability of worse chi-square:,'+string(chisqr_prob)+' %')

	period_sim = interpol([0,10], 1000)
	flux_sim = p[0]*period_sim^2.0 + p[1]
	oplot, period_sim, flux_sim, linestyle=1


stop
END		