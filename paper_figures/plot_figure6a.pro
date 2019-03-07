pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.5
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=8, $ ; 6.5
          ysize=8, $ ; 2.8
          /encapsulate, $
          yoffset=5, $
          bits_per_pixel = 16

end


pro plot_figure6a, postscript=postscript

	!p.charsize=1.5

	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	time_peak = anytim('2014-04-18T12:56:32', /utim)
	time_trough = anytim('2014-04-18T12:56:33.5', /utim)
	freq0 = 170
	freq1 = 300
	time0 = '20140418_125530'
	time1 = '20140418_125550'
	trange = anytim(file2time([time0, time1]), /utim)
	date_string = time2file(file2time(time0), /date)


	;restore, orfees_folder+'orf_'+date_string+'_bsubbed_minimum.sav', /verb
	restore, orfees_folder+'orf_'+date_string+'_raw_sfu.sav', /verb
	orf_spec = orfees_struct.spec
	orf_time = orfees_struct.time
	orf_freqs = orfees_struct.freq

	orf_spec = constbacksub(orf_spec, /auto)

	orf_freqs = reverse(orf_freqs)
	ind_f0 = closest(orf_freqs, freq0)
	ind_f1 = closest(orf_freqs, freq1)
	ind_t0 = closest(orf_time, time_peak)
	peak_spectrum = smooth(orf_spec[ind_t0, ind_f1:ind_f0], 2, /edge_mirror)
	
	;***********************************;
	;	 Plot peak intensity spectrum
	if keyword_set(postscript) then begin
		setup_ps, orfees_folder+'pulsation_flux_spec_fit.eps'
	endif else begin
		loadct, 0
		window, 1, xs=800, ys=800
	endelse	
	

	freq = orf_freqs[ind_f1:ind_f0]
	plot, orf_freqs[ind_f1:ind_f0], peak_spectrum,  $
		;xr=[freq1, freq0], $
		yr=[100, 1000], $
		xr=[freq0, freq1], $
		/xs, $
		/ys, $ 
		thick=6, $
		;xtickformat='(A1)', $
		;ytickformat='(A1)', $
		ytitle='Flux density (SFU)', $
		xtitle='Frequency (MHz)', $
		;position = [0.05, 0.05, 0.85, 0.85], $
		/noerase, $
		/ylog;, $
		;/xlog

	;axis, yaxis=1, ytitle='Flux density (SFU) ', yr=[100, 1000]

	;*************************************;
	;	 Plot trough intensity spectrum
	ind_t0 = closest(orf_time, time_trough)
	trough_spectrum = smooth(orf_spec[ind_t0, ind_f1:ind_f0], 2, /edge_mirror)	
	oplot, freq, trough_spectrum, linestyle=3, thick=2



	;*************************************;
	;	 Fit positibe slope
	freq0 = 195
	freq1 = 208
	time0 = '20140418_125530'
	time1 = '20140418_125550'
	ind_f0 = closest(orf_freqs, freq0)
	ind_f1 = closest(orf_freqs, freq1)
	ind_t0 = closest(orf_time, time_peak)
	pos_spec = reverse(transpose(alog10(orf_spec[ind_t0, ind_f1:ind_f0])))
	freq = reverse(alog10(orf_freqs[ind_f1:ind_f0]))
	result0 = linfit(freq, pos_spec, yfit=yfit)
	freq_sim = alog10(findgen(100)*300/99.)
	flux_sim = result0[0] + result0[1]*freq_sim
	set_line_color
	oplot, 10^freq_sim, 10^flux_sim, color=6, thick=5, linestyle=0


	;*************************************;
	;	 Fit negative slope
	freq0 = 208
	freq1 = 225
	time0 = '20140418_125530'
	time1 = '20140418_125550'
	ind_f0 = closest(orf_freqs, freq0)
	ind_f1 = closest(orf_freqs, freq1)
	ind_t0 = closest(orf_time, time_peak)
	pos_spec = reverse(transpose(alog10(orf_spec[ind_t0, ind_f1:ind_f0])))
	freq = reverse(alog10(orf_freqs[ind_f1:ind_f0]))
	result1 = linfit(freq, pos_spec, yfit=yfit)
	freq_sim = alog10(findgen(100)*300/99.)
	flux_sim = result1[0] + result1[1]*freq_sim
	set_line_color
	oplot, 10^freq_sim, 10^flux_sim, color=5, thick=5, linestyle=0


	print, 'Pos slope: '+string(result0[1])
	print, 'Neg slope: '+string(result1[1])

	if keyword_set(postscript) then device, /close
	set_plot, 'x'







	;*************************************;
	;	 Plot diff intensity spectrum
	;window, 2, xs=600, ys=600
	diff_spec = trough_spectrum - peak_spectrum
	oplot, orf_freqs[ind_f1:ind_f0], diff_spec, linestyle=3




stop
	;***********************************;
	;	 Plot average intensity spectrum
	loadct, 0
	window, 1, xs=600, ys=600
	time0 = anytim('2014-04-18T12:55:00', /utim)
	time1 = anytim('2014-04-18T12:57:30', /utim)
	ind_t0 = closest(orf_time, time0)
	ind_t1 = closest(orf_time, time1)

	orf_spec_section = orf_spec[ind_t0:ind_t1, ind_f1:ind_f0]

	;stop
	mean_spectrum = smooth(mean(orf_spec_section, dim=1), 2, /edge_mirror)
	loadct, 0

	plot, orf_freqs[ind_f1:ind_f0], mean_spectrum,  $
		;xr=[freq1, freq0], $
		yr=[100, 1000], $
		xr=[freq0, freq1], $
		/xs, $
		/ys, $ 
		;ytickformat='(A1)', $
		ytitle='Flux density (SFU) ', $
		xtitle='Freq (MHz)', $
		position = pos, $
		/noerase, $
		/ylog;, $
		;/xlog

	;set_line_color
	;oplot, [228, 228], [100, 1000], color=3
	;oplot, [228, 228], [100, 1000], color=3
	;oplot, [228, 228], [100, 1000], color=3















END
