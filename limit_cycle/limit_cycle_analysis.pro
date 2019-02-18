pro limit_cycle_analysis

	; A non-linear limit cycle predicts that the Flux I ~ period t^2. This code attempts to 
	; find (or not) such a relationship.

	; This is for NRH data. When source P and Q together 'nrh_228_pulse_src1left_props_hires_si.sav' are
	; analysed then there is some level of F~t^2, but chi-squared analysis says to reject this.

	; The correlation gets worse when only source P is analysed e.g., 'nrh_228_pulse_src1left_props_hires_si.sav'

	loadct, 0
	!p.background=50
	window, 0, xs=800, ys=600

	;-------------------------------------------;
	;	 Plot Stokes I NRH source properties
	;	
	restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src1_props_hires_si.sav', /verb	
	times = anytim(xy_arcs_struct.times, /utim)
	temp = xy_arcs_struct.Tb
	flux = xy_arcs_struct.flux_density

	t0 = anytim('2014-04-18T12:54:50', /utim)
	t1 = anytim('2014-04-18T12:57:10', /utim)
	index = where(times gt t0 and times lt t1)
	times = times[index]
	flux = flux[index]

	times = times - times[0]
	;flux = flux - smooth(flux, 50, /edge_mirror)
	flux = smooth(flux, 5, /edge_mirror)

	times_fine = interpol( [ 0, times[n_elements(times)-1] ], 1e4)
	flux_fine = interpol(flux, times, times_fine, /spline)	

	loadct, 0
	;set_line_color
	plot, times, flux, $
		/xs, $
		/ys, $
		ytitle='Flux (SFU)', $
		;xtickformat='(A1)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = 'Time UT', $
  		;yr=[10, 220], $
  		xr=xrange, $
		/normal, $
		/noerase, $
		color=150, $
		position=[0.05, 0.7, 0.95, 0.95], $
		psym=1	

	set_line_color
	oplot, times_fine, flux_fine, psym=3, color=6
	

	;------------------------------------------;
	;
	;			 First derivative
	;
	deriv1 = deriv(flux_fine)
	;deriv1_fine = interpol(deriv1, times, times_fine)

	set_line_color
	plot, times_fine, deriv1, $
		/xs, $
		/ys, $
		ytitle='Flux (SFU)', $
		;xtickformat='(A1)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = 'Time UT', $
  		;yr=[10, 220], $
  		xr=xrange, $
		/normal, $
		/noerase, $
		position=[0.05, 0.45, 0.95, 0.7], $
		psym=3, $
		color=1		


	;----------------------------------------------------------------;
	;
	;	Find peaks and troughs  from first derivative zero crossing
	;
	zeros = [0]
	time_zeros = times_fine[0]

	for i=1, n_elements(deriv1)-1 do begin

		delta = deriv1[i]*deriv1[i-1]

		if delta lt 0.0 then begin
			zero_point = mean( [deriv1[i], deriv1[i-1]] )
			time_zero_point = mean( [times_fine[i], times_fine[i-1]] )

			zeros = [zeros, zero_point]
			time_zeros = [time_zeros, time_zero_point]
		endif	
	endfor

	oplot, time_zeros, zeros, psym=1, color=6

	turn_time = time_zeros
	turn_flux = interpol(flux_fine, times_fine, turn_time)

	;----------------------------------------------------;
	;
	;		Plot peaks on original time profile
	;
	loadct, 0
	;set_line_color
	plot, times, flux, $
		/xs, $
		/ys, $
		ytitle='Flux (SFU)', $
		xtickformat='(A1)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = 'Time UT', $
  		;yr=[10, 220], $
  		xr=xrange, $
		/normal, $
		/noerase, $
		color=150, $
		position=[0.05, 0.7, 0.95, 0.95], $
		psym=1	

	set_line_color
	oplot, times_fine, flux_fine, psym=3, color=6
	oplot, turn_time, turn_flux, psym=1, color=5

	;------------------------------------------;
	;
	;		Separate troughs and peaks
	;
	peaks = 0
	peak_times = 0
	troughs = 0
	trough_times = 0
	pulse_period = 0
	pulse_flux = 0

	for i=1, n_elements(turn_flux)-2 do begin
		delta = turn_flux[i] - turn_flux[i-1]
		if delta gt 0.0 then begin
			peaks = [ peaks, turn_flux[i] ]	
			peak_times = [ peak_times, turn_time[i] ]

			pulse_flux = [ pulse_flux, turn_flux[i] - turn_flux[i-1] ]
			pulse_period = [ pulse_period, turn_time[i+1] - turn_time[i-1] ]

		endif else begin
			troughs = [ troughs, turn_flux[i] ]
			trough_times = [ trough_times, turn_time[i] ]
		endelse
	endfor

	oplot, trough_times, troughs, psym=1, color=4
	oplot, peak_times, peaks, psym=1, color=10

	pulse_period = pulse_period[where(pulse_flux gt 1.1)]
	pulse_flux = pulse_flux[where(pulse_flux gt 1.1)]

	plotsym, 0, /fill
	window, 1, xs=500, ys=500
	tsquared = double(pulse_period^2)
	pulse_flux = double(pulse_flux)

	plot, pulse_period, pulse_flux, $
		xtitle='Pulse period (s)', $
		ytitle='Pulse flux (SFU)', $
		psym=8, $
		;/ylog, $
		;yr=[1e-1, 1e2], $
		charsize=1.5

	yerr = replicate(10.0, n_elements(pulse_flux))
	weights = 1.0/pulse_flux

	start = [1.0, 1.0, 1.0]		
	fit = 'p[0]*x^p[2] + p[1]'	
	p = mpfitexpr(fit, pulse_period, pulse_flux, $
					yerr, $
					yfit=yfit, $
					weights=weights, $
					start, $
					perror = perror, $
					bestnorm = bestnorm, $
					dof=dof,$
					NITER=100.)	

	;oplot, yfit
	chisqr_prob = (1.0-chisqr_pdf(bestnorm, dof))
	box_message, str2arr('Probability of worse chi-square:,'+string(chisqr_prob)+' %')

	period_sim = interpol( [0, 5], 1000)
	flux_sim = p[0]*period_sim^p[2] + p[1]
	oplot, period_sim, flux_sim

	pcc = correlate(pulse_period^2.0, pulse_flux)
	print, 'Pearson CC: '+string(pcc)
stop
	;----------------------------------------------------;
	;
	;			Limit cycle expectation
	;
	start = [4.0, 1.0]		
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