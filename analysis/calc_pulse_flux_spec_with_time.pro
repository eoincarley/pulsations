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


pro calc_pulse_flux_spec_with_time, postscript=postscript

	!p.charsize=1.5

	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	time_start = anytim('2014-04-18T12:54:30', /utim)
	time_stop = anytim('2014-04-18T12:57:30', /utim)
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
	

	ind_t = closest(orf_time, time_start)
	ind_t0 = ind_t
	tim = orf_time[ind_t]

	while tim lt time_stop do begin

		
		;***********************************;
		;	 Plot peak intensity spectrum
		if keyword_set(postscript) then begin
			setup_ps, orfees_folder+'pulsation_flux_spec_fit.eps'
		endif else begin
			loadct, 0
			window, 1, xs=800, ys=800
		endelse	
		
		freq0 = 170
		freq1 = 300
		ind_f0 = closest(orf_freqs, freq0)
		ind_f1 = closest(orf_freqs, freq1)
		freq = orf_freqs[ind_f1:ind_f0]
		peak_spectrum = smooth(orf_spec[ind_t, ind_f1:ind_f0], 2, /edge_mirror)
		plot, freq, peak_spectrum,  $
			;xr=[freq1, freq0], $
			yr=[10, 1e4], $
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

		;*************************************;
		;	 Fit positibe slope
		freq0 = 195
		freq1 = 208
		time0 = '20140418_125530'
		time1 = '20140418_125550'
		ind_f0 = closest(orf_freqs, freq0)
		ind_f1 = closest(orf_freqs, freq1)
		;ind_t = closest(orf_time, time_start)
		pos_spec = reverse(transpose(alog10(orf_spec[ind_t, ind_f1:ind_f0])))
		freq = reverse(alog10(orf_freqs[ind_f1:ind_f0]))
		result0 = linfit(freq, pos_spec, yfit=yfit)
		freq_sim = alog10(findgen(100)*300/99.)
		flux_sim = result0[0] + result0[1]*freq_sim
		set_line_color
		oplot, 10^freq_sim, 10^flux_sim, color=3, thick=4, linestyle=2


		;*************************************;
		;	 Fit negative slope
		freq0 = 208
		freq1 = 225
		time0 = '20140418_125530'
		time1 = '20140418_125550'
		ind_f0 = closest(orf_freqs, freq0)
		ind_f1 = closest(orf_freqs, freq1)
		;ind_t = closest(orf_time, time_peak)
		pos_spec = reverse(transpose(alog10(orf_spec[ind_t, ind_f1:ind_f0])))
		freq = reverse(alog10(orf_freqs[ind_f1:ind_f0]))
		result1 = linfit(freq, pos_spec, yfit=yfit)
		freq_sim = alog10(findgen(100)*300/99.)
		flux_sim = result1[0] + result1[1]*freq_sim
		set_line_color
		oplot, 10^freq_sim, 10^flux_sim, color=5, thick=4, linestyle=2


		if ind_t0 eq ind_t then begin
			max_flux = max(peak_spectrum)
			pos_index = result0[1]
			neg_index = result1[1]
			time = tim
		endif else begin
			max_flux = [max_flux, max(peak_spectrum)]
			pos_index = [pos_index, result0[1]]
			neg_index = [neg_index, result1[1]]
			time = [time, tim]
		endelse	


		ind_t = ind_t+1
		tim = orf_time[ind_t]

	endwhile

	save, max_flux, pos_index, neg_index, time, filename='~/Data/2014_apr_18/radio/orfees/pulse_flux_spectra.sav'

	time_start = anytim('2014-04-18T12:54:00', /utim)
	time_stop = anytim('2014-04-18T12:57:30', /utim)
	set_line_color
	utplot, time, pos_index, /xs, yr=[0, 22], xr =[time_start, time_stop]
	outplot, time, abs(neg_index)

	stop

END
