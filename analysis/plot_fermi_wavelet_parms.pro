pro plot_fermi, date_start, date_end, plt_pos=plt_pos, yrange=yrange, second_fermi=second_fermi, scale=scale, $
	fermi_time=fermi_time, fermi_flux=fermi_flux


	FermiGBM_file= '~/Data/2014_apr_18/fermi/fermi_ctime_n0_20140418_v00.sav'   

	restore, FermiGBM_file
	ind0=2
	tims_ut = anytim(ut, /utim)
	fermi = binned[ind0,*]
	fermi = gauss_smooth(fermi, 5)*scale
	coeff = DETREND(fermi, flux, ORDER=10)


	indices = where(tims_ut gt date_start and tims_ut lt date_end)
	tims_ut = tims_ut[indices]
	flux = flux[indices]
	;flux = flux/gauss_smooth(flux, 100)

	set_line_color
	utplot, tims_ut, flux, $
			;/ylog, $
			;yrange=yrange, $
			position=plt_pos, $
			;/nolabel, $
			xtitle=' ', $
			;XTICKFORMAT="(A1)", $
			;YTICKFORMAT="(A1)", $
			yticklen=-1e-2, $
			/noerase, $
			timerange=[date_start, date_end], $
			ytitle='counts [s!u-1!n cm!u-2!n keV!u-1!n]', $
			/xs, $
			/ys, $
			thick=1, $
			color=1

	outplot, tims_ut, flux, col=10		

	fermi_time = tims_ut
	fermi_flux = flux

END




pro plot_fermi_wavelet_parms, postscript=postscript, use_detrend=use_detrend


	; Test to see how detrend params affect peak period.

	;------------------------------------;
	;			Window params
	;
	loadct, 0
	window, 0, xs=800, ys=1000
	window, 1, xs=500, ys=500

	ypos = 0.98
	plot_delt = 0.2
	del_inc = 0.04
	pos0 = [0.1, ypos-plot_delt*1.0, 0.93, ypos]
	pos1 = [0.1, ypos-plot_delt*2.0 - del_inc, 0.93, ypos-plot_delt*1.0 - del_inc]
	pos2 = [0.1, ypos-plot_delt*4.0 - del_inc, 0.93, ypos-plot_delt*2.4 - del_inc]


	time0 = anytim('2014-04-18T12:56:00', /utim)
	time1 = anytim('2014-04-18T12:58:00', /utim)
	
	FermiGBM_file= '~/Data/2014_apr_18/fermi/fermi_ctime_n0_20140418_v00.sav'   
	restore, FermiGBM_file
	eindex=3
	tims_ut = anytim(ut, /utim)
	fermi_flux = binned[eindex, *]

	smoother = interpol([2,10],100)
	detrender = interpol([20,50],100)
	param_space = fltarr(n_elements(smoother), n_elements(detrender))

	for sindex=0, n_elements(detrender)-1 do begin
		for pindex=0, n_elements(smoother)-1 do begin
			fermi_flux = gauss_smooth(fermi_flux, 5.5)
			flux_lscale = gauss_smooth(fermi_flux, 30)

			indices = where(tims_ut ge time0 and tims_ut le time1)
			tims_ut = tims_ut[indices]
			fermi_flux = fermi_flux[indices]
			flux_lscale = flux_lscale[indices]

			;coeff = DETREND(fermi_flux, detrended_flux, ORDER=11)
			lcurve = fermi_flux

			window, 0, xs=800, ys=1000
			utplot, tims_ut, lcurve, $
				/xs, /ys, $
				pos=pos0
			set_line_color	
			outplot, tims_ut, flux_lscale, color=4	
			
			lcurve_detrend = fermi_flux/flux_lscale
			utplot, tims_ut, lcurve_detrend, $
				/xs, /ys, $
				pos=pos1, $
				/noerase

			time_array=tims_ut

			;--------------------------------------------;
			;              Wavelet analysis
			;--------------------------------------------;
			dt = time_array[1]  - time_array[0]
			tsec = time_array - time_array[0]
			if keyword_set(use_detrend) then lcurve = transpose(transpose(lcurve_detrend)) $
				else lcurve = transpose(transpose(lcurve))

			wave = wavelet(lcurve, $
					dt, $
					mother='morlet', $
					period = period, $
					coi=coi, $
					SIGNIF=signif, $
					/pad, $
					S0=dt*2.0, $
					SCALE=scale, $
					fft_theor = fft_theor)


			;--------------------------------------------;
			;           Plot wavelet spectrum
			;--------------------------------------------;
			; It took a lot of playing around with colour stretching and scaling the dat to make look right.
			; Without it, the lowest values in wave are plotted as white in the postscript. Couldn't figure out
			; what the issue was.	
			loadct, 74
			;stretch, 50.0, 255.0	
			wave = abs(wave)^2.0
			for i=0, n_elements(period)-1 do wave[*, i] = wave[*, i]/period[i]

			CONTOUR, wave, tsec, period, $
				/xs, $
				/ys, $
				XTITLE='Time in seconds after ' + anytim(time_array[0], /yoh, /time_only, /trun) + ' UT', $ 
				YTITLE='Period (s)', $ 
				YRANGE=[MAX(period), 0.8], $   ;*** Large-->Small period
				/YTYPE, $                              ;*** make y-axis logarithmic
				NLEVELS=25, $
				/FILL, $
				position = pos2, $
				/normal, $
				/noerase, $
				xticklen = -0.01, $
				yticklen = -0.01, $
				title = 'DOG wavelet spectrogram'		
			
			wave_y =wave
			wave_z =wave

			FOR i = 0, n_elements(wave[*,0])-1 DO BEGIN
		        	index = where(period lt coi[i])
		        	IF index[0] ne -1 THEN BEGIN
		                	wave_y[i, index] = !values.f_nan
		                	wave_z[i, index] = 0.0
		        	ENDIF
			ENDFOR

			;----------------------------------------------------------;
			;     Plot regions outside the cone of influence in grey
			;----------------------------------------------------------;
			loadct, 0
			CONTOUR, wave_z > (-10) <7, tsec, period, $
				YRANGE=[MAX(period), 0.8], $   ;*** Large-->Small period
				/YTYPE, $                              ;*** make y-axis logarithmic
				NLEVELS=25, $
				/xs, $
				/ys, $
				/FILL, $
				/noerase, $
				position = pos2, $	
				xticklen = -0.01, $
				yticklen = -0.01
				
			
			;-------------------------------;
			;   Plot significance levels	;
			;-------------------------------;
			ntime = n_elements(time_array)
			nscale = N_ELEMENTS(period)
			signif = WAVE_SIGNIF(lcurve, dt, scale)
			signif = REBIN(TRANSPOSE(signif), ntime, nscale)
		    ;signif = REBIN(TRANSPOSE(signif), ntime, nscale)

		    set_line_color
			CONTOUR, wave/signif, tsec, $
				period, $
		      	/OVERPLOT, $
				LEVEL=0.95, $
				C_ANNOT='95%', $
				color=4, $
				position = pos2

			PLOTS, tsec, coi, $
				NOCLIP=0 , $
				thick=3, $
				color=4, $
				linestyle=0

			wset, 1
			power1D = total(wave,1)
			plot, period, power1D, /xlog, $
				xtitle='Period (s)', $
				ytitle='Total Power', $
				charsize=1.2, $
				pos=[0.15, 0.1, 0.9, 0.9], $
				xr=[1, 20], $
				/xs
			peak=max(power1D)	
			param_space[i,j]=peak
		endfor	
	endfor	

stop	
END

