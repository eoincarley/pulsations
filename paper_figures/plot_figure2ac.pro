pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.0
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=9, $
          ysize=12, $
          /encapsulate, $
          yoffset=5, $
          bits_per_pixel = 16

end

pro plot_spec, data, time, freqs, frange, trange, scl0=scl0, scl1=scl1, x0pos=x0pos, x1pos=x1pos
	

	print, 'Processing: '+string(freqs[0], format=string('(I4)')) + $
			' to ' + $
			string(freqs[n_elements(freqs)-1], format=string('(I4)'))+ ' MHz'

	trange = anytim(file2time(trange), /utim)
	spectro_plot, smooth(data,1) > (scl0) < (scl1), $
  				time, $
  				freqs, $
  				/xs, $
  				/ys, $
  				/ylog, $
				XTICKFORMAT="(A1)", $
				YTICKFORMAT="(A1)", $
				xticklen=-1e-5, $
				yticklen=-1e-5, $
				xtitle=' ', $
  				;ytitle='Frequency (MHz)', $
  				;title = 'Orfees and DAM', $
  				yr=[ frange[0], frange[1] ], $
  				xrange = [ trange[0], trange[1] ], $
  				/noerase, $
  				position = [x0pos, 0.5, x1pos, 0.79]
		
  	
END

function read_goes_txt, file

	readcol, file, y, m, d, hhmm, mjd, sod, short_channel, long_channel
	
	;-------- Time in correct format --------
	time  = strarr(n_elements(y))
	
	time[*] = string(y[*], format='(I04)') + string(m[*], format='(I02)') $
	  + string(d[*], format='(I02)') + '_' + string(hhmm[*], format='(I04)')
	    
	time = anytim(file2time(time), /utim) 
	
	;------- Build data array --------------

	goes_array = dblarr(3, n_elements(y))
	goes_array[0,*] = time
	goes_array[1,*] = long_channel
	goes_array[2,*] = short_channel
	return, goes_array

END

;**********************************************;
;				Plot GOES

pro plot_goes, t1, t2, x0pos=x0pos, x1pos=x1pos

		x1 = anytim(file2time(t1), /utim)
		x2 = anytim(file2time(t2), /utim)
		
		;--------------------------------;
		;			 Xray
		file = findfile('~/Data/2014_apr_18/goes/20140418_Gp_xr_1m.txt')
		goes = read_goes_txt(file[0])
	
		set_line_color
		utplot, goes[0,*], goes[1,*], $
				thick = 1, $
				;tit = '1-minute GOES-15 Solar X-ray Flux', $
				ytit = 'Watts m!U-2!N', $
				xtit = ' ', $
				color = 3, $
				xrange = [x1, x2], $
				XTICKFORMAT="(A1)", $
				/xs, $
				yrange = [1e-9,1e-3], $
				/ylog, $
				position = [x0pos, 0.8, x1pos, 0.98], $
				/normal, $
				/noerase
				
		outplot, goes[0,*], goes[2,*], color=5	
		
		axis, yaxis=1, ytickname=[' ','A','B','C','M','X',' ']
		axis, yaxis=0, yrange=[1e-9, 1e-3]
		
		i1 =  closest(goes[0,*], x1)
		i2 = closest(goes[0,*], x2)
		plots, goes[0, i1:i2], 1e-8
		plots, goes[0, i1:i2], 1e-7
		plots, goes[0, i1:i2], 1e-6
		plots, goes[0, i1:i2], 1e-5
		plots, goes[0, i1:i2], 1e-4
				
		outplot, goes[0,*], goes[1,*], color=3	
		outplot, goes[0,*], goes[2,*], color=5	
				
		legend, ['GOES15 0.1-0.8nm','GOES15 0.05-0.4nm'], $
				linestyle=[0,0], $
				color=[3,5], $
				box=0, $
				pos = [0.12, 0.98], $
				/normal, $
				charsize=1.2, $
				thick=3

		;xyouts, 0.925, 0.96, 'a', /normal		

END


pro plot_figure2ac, postscript=postscript

	; For Figure 2 of the paper.

	;------------------------------------;
	;			Window params
	;
	loadct, 0
	reverse_ct
	cd,'~/Data/2014_apr_18/
	dam_folder = '~/Data/2014_apr_18/radio/dam/'
	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	freq0 = 10
	freq1 = 1000
	time0 = '20140418_122500'
	time1 = '20140418_132000'
	date_string = time2file(file2time(time0), /date)
	x0pos = 0.08
	x1pos = 0.91

	if keyword_set(postscript) then begin
		setup_ps, '~/Data/2014_apr_18/pulsations/goes_nda_orfees_pulse_20140418.eps
	endif else begin	
		loadct, 0
		!p.charsize=1.0
		!p.color=255
		!p.background=100
		window, 0, xs=900, ys=1200, retain=2
	endelse			

		;***********************************;
		;			Plot GOES		
		;***********************************;
		set_line_color
		plot_goes, time0, time1, x0pos=x0pos, x1pos=x1pos

		;***********************************;
		;		Read and process DAM		
		;***********************************;
		
		cd, dam_folder
		restore, 'NDA_'+date_string+'_1051.sav', /verb
		dam_freqs = nda_struct.freq
		daml = nda_struct.spec_left
		damr = nda_struct.spec_right
		times = nda_struct.times

		restore, 'NDA_'+date_string+'_1151.sav', /verb
		daml = [daml, nda_struct.spec_left]
		damr = [damr, nda_struct.spec_right]
		times = [times, nda_struct.times]

		restore, 'NDA_'+date_string+'_1251.sav', /verb
		daml = [daml, nda_struct.spec_left]
		damr = [damr, nda_struct.spec_right]
		times = [times, nda_struct.times]
		
		dam_spec = damr + daml
		dam_time = times
		
		dam_tim0 = anytim(file2time(time0), /time_only, /trun, /yoh)
		dam_tim1 = anytim(file2time(time1), /time_only, /trun, /yoh)

		;dam_spec = slide_backsub(dam_spec, dam_time, 15.0*60.0, /minimum)	
		;dam_spec = simple_pass_filter(dam_spec, dam_time, dam_freqs, /low_pass, /time_axis, smoothing=10)	
		
		dam_spec = alog10(dam_spec)	
		dam_spec = constbacksub(dam_spec, /auto)
		dam_spec = dam_spec*3.0


		;***********************************;
		;	Read and pre-processed Orfees		
		;***********************************;	

		restore, orfees_folder+'orf_20140418_bsubbed_minimum_sfu.sav', /verb
		orf_spec = orf_spec/max(orf_spec)
		orf_spec = orf_spec*3.3  	; Scale arbitrarily so it fits 0-1 intensity range. Neater for colorbar
		;orf_spec = orfees_struct.spec
		;orf_time = orfees_struct.time
		;orf_freqs = reverse(orfees_struct.freq)
		;orf_spec = slide_backsub(orf_spec, orf_time, 25.0*60.0, /minimum)	

	


		;skip_orfees: print, 'Skipped Orfees.'
		;***********************************;
		;			   PLOT
		;***********************************;	

  		loadct, 74, /silent
		reverse_ct
		
		scl_lwr = -0.4				;Lower intensity scale for the plots.		

		plot_spec, dam_spec, dam_time, dam_freqs, [freq0, freq1], [time0, time1], scl0=0.0, scl1=1.0, x0pos=x0pos, x1pos=x1pos
		
		plot_spec, orf_spec, orf_time, orf_freqs, [freq0, freq1], [time0, time1], scl0=0.0, scl1=1.0, x0pos=x0pos, x1pos=x1pos
		
		loadct, 0, /silent
		plot_times = anytim(file2time([time0, time1]), /utim)
		utplot, plot_times, [freq1, freq0],	$
				/xs, $
  				/ys, $
  				/ylog, $
				/nodata, $
  				ytitle='Frequency (MHz)', $
  				xtitle='Time (UT)', $
  				yr=[freq1, freq0 ], $
  				xrange = plot_times, $
  				/noerase, $
  				position = [x0pos, 0.5, x1pos, 0.79], $
  				xticklen = -0.012, $
  				yticklen = -0.015

  		;***********************************;
		;			Plot Zoom
		;***********************************;	
		freq0 = 170
		freq1 = 300
		time0 = '20140418_125400'
		time1 = '20140418_125740'	
		scl0 = 0.0
		scl1 = 1.0	
  		;plot_spec, orf_spec, orf_time, reverse(orf_freqs), [freq0, freq1], [time0, time1], scl0=-0.1, scl1=1.2
		
  		loadct, 74, /silent
  		reverse_ct
  		
		trange = anytim(file2time([time0, time1]), /utim)
		spectro_plot, orf_spec > scl0 < scl1, $
	  				orf_time, $
	  				orf_freqs, $
	  				/xs, $
	  				/ys, $
	  				;/ylog, $
					XTICKFORMAT="(A1)", $
					YTICKFORMAT="(A1)", $
					xticklen=-0.5e-5, $
					yticklen=-0.5e-5, $
					xtitle=' ', $
	  				yr = [ freq0, freq1 ], $
	  				xrange = [ trange[0], trange[1] ], $
	  				/noerase, $
	  				position = [x0pos, 0.25, x1pos, 0.45]

		loadct, 0
		plot_times = anytim(file2time([time0, time1]), /utim)
		utplot, plot_times, [freq1, freq0],	$
				/xs, $
  				/ys, $
  				;/ylog, $
				/nodata, $
  				ytitle='Frequency (MHz)', $
  				xtitle='Time (UT)', $
  				yr=[freq1, freq0 ], $
  				xrange = plot_times, $
  				/noerase, $
  				position = [x0pos, 0.25, x1pos, 0.45], $
  				xticklen = -0.012, $
  				yticklen = -0.013
	
  		;------------------------------------------;
  		;			For Orfées Zoom
  		;
		;set_line_color
		;cgColorbar, Range=[scl0, scl1], $
	    ;   OOB_Low='rose', OOB_High='charcoal', /vertical, /right, title='a.u.', $
	    ;   position = [0.92, 0.22, 0.93, 0.32 ], charsize=0.9, color=0, OOB_FACTOR=0.0, format='(f3.1)', $
	    ;   TICKINTERVAL = 0.1

	    ;loadct, 74
		;reverse_ct
	  	;cgColorbar, Range=[scl0, scl1], $
	    ;   OOB_Low='rose', OOB_High='charcoal', title='  ', /vertical, /right, $
	    ;   position = [0.92, 0.22, 0.93, 0.32 ], charsize=0.9, color=100, ytickformat='(A1)', OOB_FACTOR=0.0, format='(f3.1)', $
	    ;   TICKINTERVAL = 0.1

	    ;------------------------------------------;
  		;			For Orfées 
  		;
	    set_line_color
		cgColorbar, Range=[scl0, scl1], $
	       OOB_Low='rose', OOB_High='charcoal', /vertical, /right, title='Normalised Flux', $
	       position = [0.925, 0.5, 0.937, 0.79 ], charsize=1.0, color=0, OOB_FACTOR=0.0, format='(f3.1)', $
	       TICKINTERVAL = 0.2

	    loadct, 74
	    reverse_ct
	  	cgColorbar, Range=[scl0, scl1], $
	       OOB_Low='rose', OOB_High='charcoal', title='  ', /vertical, /right, $
	       position = [0.925, 0.5, 0.937, 0.79 ], charsize=1.0, color=100, ytickformat='(A1)', OOB_FACTOR=0.0, format='(f3.1)', $
	       TICKINTERVAL = 0.2

	    ;---------------------------------;
  		;			For NDA 
  		;
	    ;set_line_color
		;cgColorbar, Range=[0.0, 0.3], $
	    ;   OOB_Low='rose', OOB_High='charcoal', /vertical, /right, title='a.u.', $
	    ;   position = [0.92, 0.66, 0.93, 0.76 ], charsize=0.9, color=0, OOB_FACTOR=0.0, format='(f3.1)', $
	    ;   TICKINTERVAL = 0.2

	    ;loadct, 74
		;reverse_ct
	  	;cgColorbar, Range=[0.0, 0.4], $
	    ;   OOB_Low='rose', OOB_High='charcoal', title='  ', /vertical, /right, $
	    ;   position = [0.92, 0.66, 0.93, 0.76 ], charsize=0.9, color=100, ytickformat='(A1)', OOB_FACTOR=0.0, format='(f3.1)', $
	    ;   TICKINTERVAL = 0.2   

	
	if keyword_set(postscript) then begin
		device, /close
		set_plot, 'x'
	endif

;	x2png,'dam_orfees_burst_20140418.png'
	
stop
END