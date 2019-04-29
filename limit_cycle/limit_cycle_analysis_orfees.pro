pro limit_cycle_analysis_orfees

	; A non-linear limit cycle predicts that the Flux I ~ period t^2. This code attempts to 
	; find (or not) such a relationship.
	loadct, 0
	!p.background=50
	window, 0, xs=1200, ys=600

	;-----------------------------------;
	;			Plot Orfees 
	;
	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	freq0 = 180
	freq1 = 270

	restore, orfees_folder+'orf_20140418_raw_sfu.sav', /verb
	orf_spec = orfees_struct.spec
	orf_freqs = orfees_struct.freq
	times = anytim(orfees_struct.time, /utim)

	freq_array = reverse(orf_freqs)
	index = closest(freq_array, 210)
	flux = orf_spec[*, index]
	flux = flux - median(flux)

	t0 = anytim('2014-04-18T12:54:55', /utim)
	t1 = anytim('2014-04-18T12:57:15', /utim)
	index = where(times gt t0 and times lt t1)
	times = times[index]
	flux = flux[index]
	times = times - times[0]
	flux = smooth(flux, 3, /edge_mirror)

	times_fine = interpol( [ 0, times[n_elements(times)-1] ], 1e4)
	flux_fine = interpol(flux, times, times_fine, /spline)	

	loadct, 0
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
	deriv1 = deriv(flux_fine) ; smooth(deriv(flux_fine), 25, /edge_mirror)
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
	rise_times = 0
	decay_times = 0

	for i=1, n_elements(turn_flux)-2 do begin
		delta = turn_flux[i] - turn_flux[i-1]
		delta_t = turn_time[i] - turn_time[i-1]
		if delta gt 0.0 then begin
			peaks = [ peaks, turn_flux[i] ]	
			peak_times = [ peak_times, turn_time[i] ]

			pulse_flux = [ pulse_flux, turn_flux[i] - turn_flux[i-1] ]
			pulse_period = [ pulse_period, turn_time[i+1] - turn_time[i-1] ]

			rise_times = [rise_times, delta_t]

		endif else begin
			troughs = [ troughs, turn_flux[i] ]
			trough_times = [ trough_times, turn_time[i] ]
			decay_times = [decay_times, delta_t]
		endelse
	endfor

	oplot, trough_times, troughs, psym=1, color=4
	oplot, peak_times, peaks, psym=1, color=10

	pulse_period = pulse_period[where(pulse_period gt 0.5)]
	pulse_flux = pulse_flux[where(pulse_period gt 0.5)]

	plotsym, 0, /fill
	window, 1, xs=500, ys=500
	tsquared = pulse_period^2
	pulse_flux = pulse_flux

	plot, pulse_period, pulse_flux, $
		xtitle='Pulse period (s)', $
		ytitle='Pulse flux (SFU)', $
		psym=8, $
		/ylog, $
		yr=[1e1, 7e2], $
		charsize=1.5

	pcc = correlate(pulse_period, pulse_flux)
	print, 'Pearson CC: '+string(pcc)
		
	pulse_props = {times:times, flux:flux, times_fine:times_fine, flux_fine:flux_fine, flux_deriv:deriv1, $
							peak_times:peak_times, peaks:peaks, trough_times:trough_times, troughs:troughs, $
							time_zeros:time_zeros, zeros:zeros, pulse_period:pulse_period, pulse_flux:pulse_flux, $
							turn_time:turn_time, rise_times:rise_times, decay_times:decay_times}	

	save, pulse_props, filename='~/Data/2014_apr_18/radio/pulse_props.sav', $
		description='Pulsation peaks, troughs, amplitudes and periods. Made using limit_cycle_analysis_orfees.pro'
stop
	yerr = replicate(0.1, n_elements(pulse_flux))
	weights = 1.0/pulse_flux

	start = [5.0, 2.0, 0.1]		
	fit = 'alog10(x^p[2]) + p[1]'	
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

	period_sim = interpol([0,4], 1000)
	flux_sim = p[0]*period_sim^p[2] + p[1]
	oplot, period_sim, flux_sim
	oplot, period_sim, alog10(period_sim^2)+4.5

	pcc = correlate(pulse_period, pulse_flux)
	print, 'Pearson CC: '+string(pcc)
stop
	;----------------------------------------------------;
	;
	;			Limit cycle expectation
	;
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