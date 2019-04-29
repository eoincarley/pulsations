pro setup_ps, name

    set_plot,'ps'
    !p.font=0
    !p.charsize=1.3
    device, filename = name, $
        ;/decomposed, $
        /color, $
        /helvetica, $
        /inches, $
        xsize=12.5, $
        ysize=6, $
        /encapsulate, $
        bits_per_pixel=32, $
        yoffset=5

end

pro plot_spec, data, time, freqs, frange, trange, scl0=scl0, scl1=scl1
    

    print, 'Processing: '+string(freqs[0], format=string('(I4)')) + $
            ' to ' + $
            string(freqs[n_elements(freqs)-1], format=string('(I4)'))+ ' MHz'


    spectro_plot, data > (scl0) < (scl1), $
                time, $
                freqs, $
                /xs, $
                /ys, $
                ;/ylog, $
                ytitle='Frequency (MHz)', $
                ;title = 'Orfees and DAM', $
                yr=[ frange[0], frange[1] ], $
                xrange = [ trange[0], trange[1] ], $
                /noerase, $
                position = [0.1, 0.36, 0.9, 0.92], $
                xticklen = -0.001, $
                yticklen = -0.005, $
                xtickformat='(A1)', $
                xtitle = ' '

    ;------------------------------------------;
    ;           For Orfées 
    ;
    set_line_color
    cgColorbar, Range=[scl0, scl1], $
       OOB_Low='rose', OOB_High='charcoal', /vertical, /right, title='Normalised Flux', $
       position = [0.91, 0.36, 0.921, 0.92 ], charsize=1.2, color=0, OOB_FACTOR=0.0, format='(f3.1)', $
       TICKINTERVAL = 0.2

    loadct, 74
    reverse_ct
    cgColorbar, Range=[scl0, scl1], $
       OOB_Low='rose', OOB_High='charcoal', title='  ', /vertical, /right, $
       position = [0.91, 0.36, 0.921, 0.92 ], charsize=1.2, color=100, ytickformat='(A1)', OOB_FACTOR=0.0, format='(f3.1)', $
       TICKINTERVAL = 0.2  
            
        
    
END


pro plot_figure4de, postscript=postscript
	 
	if keyword_set(postscript) then setup_ps, '~/pulse_zooms.eps'
    ;window, 0, xs=1000, ys=500
    
    time_start = anytim('2014-04-18T12:55:20') ;
    time_end = anytim('2014-04-18T12:55:40') ;

    
    trange=[time_start, time_end]
    freq = 208

    orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
    freq0 = 200
    freq1 = 340

    date_string = time2file(trange[0], /date)

    restore, orfees_folder+'orf_'+date_string+'_bsubbed_median.sav', /verb
    orf_spec = 2.0*(smooth(orfees_struct.spec, 3) + 0.05) ; Scaled arbitrarily
    orf_time = orfees_struct.time
    orf_freqs = orfees_struct.freq

    ;***********************************;
    ;              PLOT
    ;***********************************;   

    loadct, 74, /silent
    reverse_ct
    plot_spec, orf_spec, orf_time, reverse(orf_freqs), [freq0, freq1], trange, scl0=0.0, scl1=1.0
    
    fcolors = indgen(n_elements(freq))+3

    set_line_color
    plots, trange, [freq, freq], thick=0.8, color=fcolors[0], /data 

    time0 = anytim('2014-04-18T12:55:28.140', /utim)
    time1 = anytim('2014-04-18T12:55:28.810', /utim)
    time2 = anytim('2014-04-18T12:55:29.260', /utim)
    time3 = anytim('2014-04-18T12:55:29.490', /utim)

    plots, [time0, time0], [freq1, freq0], thick=3.5, color=5, /data    
    plots, [time1, time1], [freq1, freq0], thick=3.5, color=5, /data    
    ;plots, [time2, time2], [freq1, freq0], thick=1.5, color=5, /data    
    plots, [time3, time3], [freq1, freq0], thick=3.5, color=5, /data    
    

    restore, orfees_folder+'orf_'+date_string+'_raw.sav', /verb
    orf_spec = orfees_struct.spec
    orf_time = orfees_struct.time
    orf_freqs = orfees_struct.freq
    int_range = [0.2, 0.8]
    freq_array = reverse(orf_freqs)
    index = closest(freq_array, 208.0)
    lcurve = smooth(orf_spec[*, index], 2)


    ;***********************************;
    ;    Plot 208-228 MHz Light Curve
    utplot, orf_time, lcurve/max(lcurve), $
        /xs, $
        /ys, $
        linestyle = 0, $
        color = 3, $
        thick = 4, $
        xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
        ytitle = 'Intensity (arbitrary)', $
        xtitle = 'Time (UT)', $
        position = [0.1, 0.1, 0.9, 0.35], $
        xr = trange, $
        yr = int_range, $
        /normal, $
        /noerase

    restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src1left_props_hires_si.sav', /verb   
    times = anytim(xy_arcs_struct.times, /utim)
    temp = xy_arcs_struct.Tb
    flux = alog10(smooth(xy_arcs_struct.flux_density, 2))
    outplot, times, flux/max(flux) - 0.3, color=3, linestyle=2, thick=2   


    ;-----------------------------;
    ;   Plot 298 MHz light curve
    ;
    index = closest(freq_array, 298.0)
    lcurve = orf_spec[*, index]
    outplot, orf_time, smooth(lcurve/max(lcurve),3), color=4, thick=4

    restore, '~/Data/2014_apr_18/pulsations/nrh_298_pulse_src1_props_hires_si.sav', /verb   
    times = anytim(xy_arcs_struct.times, /utim)
    temp = xy_arcs_struct.Tb
    flux = alog10(smooth(xy_arcs_struct.flux_density, 3))
    outplot, times, flux/max(flux) -0.65, color=4, linestyle=2, thick=2          


    ;-----------------------------;
    ;   Plot 327 MHz light curve
    ;
    index = closest(freq_array, 327.0)
    lcurve = orf_spec[*, index]
    outplot, orf_time, lcurve/max(lcurve), color=5, thick=4


    restore, '~/Data/2014_apr_18/pulsations/nrh_327_pulse_src1_props_hires_si.sav', /verb   
    times = anytim(xy_arcs_struct.times, /utim)
    temp = xy_arcs_struct.Tb
    flux = alog10(smooth(xy_arcs_struct.flux_density, 3))
    outplot, times, flux/max(flux) -0.65, color=5, linestyle=2, thick=2      
    

    plots, [time0, time0], [int_range], thick=3.5, color=5, /data   
    plots, [time1, time1], [int_range], thick=3.5, color=5, /data   
    ;plots, [time2, time2], [int_range], thick=1.5, color=5, /data   
    plots, [time3, time3], [int_range], thick=3.5, color=5, /data   
    

    if keyword_set(postscript) then device, /close
    set_plot, 'x'

END