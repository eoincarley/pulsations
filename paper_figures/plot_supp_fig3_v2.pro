pro setup_ps, name
  
  set_plot,'ps'
  !p.font=0
  !p.charsize=1.0
  !p.thick=4
  device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=8, $
          ysize=12, $
          /encapsulate, $
          yoffset=5

end

pro plot_supp_fig3_v2, postscript=postscript

	; Rearrange these plots to create supplementary figure 2

	; v2 now plots 228-3237 MHz fluxes and polarisations.

	; Window setup
	if keyword_set(postscript) then begin
        setup_ps, '~/Data/2014_apr_18/pulsations/nrh_pulse_src_SISV.eps
	endif else begin
		window, 0, xs=800, ys=1300, retain=2
	endelse

	set_line_color
	ypos = 0.98
	plot_delt = 0.13
	del_inc = 0.002
	pos0 = [0.1, ypos-plot_delt, 0.93, ypos]
	pos1 = [0.1, ypos-plot_delt*2.0, 0.93, ypos-plot_delt - del_inc]
	pos2 = [0.1, ypos-plot_delt*3.0, 0.93, ypos-plot_delt*2.0- del_inc]
	pos3 = [0.1, ypos-plot_delt*4.0, 0.93, ypos-plot_delt*3.0- del_inc]
	pos4 = [0.1, ypos-plot_delt*5.0, 0.93, ypos-plot_delt*4.0- del_inc]
	pos5 = [0.1, ypos-plot_delt*6.0, 0.93, ypos-plot_delt*5.0- del_inc]
	pos6 = [0.1, ypos-plot_delt*7.0, 0.93, ypos-plot_delt*6.0- del_inc]
	;pos6 = [0.1, ypos-plot_delt*6.0, 0.95, ypos-plot_delt*6.0]

	;-----------------------------------;
	;			Plot Orfees 
	;
	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	freq0 = 180
	freq1 = 270
	time0 = '2014-04-18T12:53:00'
	time1 = '2014-04-18T12:58:00'
	trange = anytim([time0, time1], /utim)
	date_string = time2file(time0, /date)

	restore, orfees_folder+'orf_'+date_string+'_bsubbed_minimum.sav', /verb
	orf_spec = orfees_struct.spec
	orf_time = orfees_struct.time
	orf_freqs = orfees_struct.freq

	freq_array = reverse(orf_freqs)
	index = closest(freq_array, 208)
	lcurve = orf_spec[*, index]

	utplot, orf_time, lcurve, $
		/xs, $
		/ys, $
		linestyle = 0, $
		color = 0, $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
		ytitle = 'Intensity (arbitrary)', $
		xtickformat='(A1)', $
  		xtitle = ' ', $
		position = pos0, $
		xr = trange, $
		yr=[0.1, 1.2], $
		/normal, $
		/noerase


	;-------------------------------------------;
	;	 Plot Stokes I NRH source properties
	;	
	restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src1_props_hires_si.sav', /verb	
	times = anytim(xy_arcs_struct.times, /utim)
	temp = xy_arcs_struct.Tb
	flux = xy_arcs_struct.flux_density
	
	utplot, times, flux, $
		/xs, $
		/ys, $
		/ylog, $
		ytitle='Flux (SFU)', $
		xtickformat='(A1)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = ' ', $
  		yr=[3, 210], $
		position = pos1, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=3

	loadct, 0	
	plotlinsy = [findgen(10), 1e1*findgen(10), 1e2*findgen(10)]
	for i=0, n_elements(plotlinsy)-1 do outplot, [times[0], times[n_elements(times)-1]], [plotlinsy[i], plotlinsy[i]], color=140, linestyle=0, thick=0.5
	set_line_color
	outplot, times, flux, color=3	

	restore, '~/Data/2014_apr_18/pulsations/nrh_298_pulse_src1_props_hires_si.sav', /verb	
	times = anytim(xy_arcs_struct.times, /utim)
	temp = xy_arcs_struct.Tb
	flux = xy_arcs_struct.flux_density	
	outplot, times, flux, color=4

	restore, '~/Data/2014_apr_18/pulsations/nrh_327_pulse_src1_props_hires_si.sav', /verb	
	times = anytim(xy_arcs_struct.times, /utim)
	temp = xy_arcs_struct.Tb
	flux = xy_arcs_struct.flux_density	
	outplot, times, flux, color=5

	;-------------------------------------------;
	;	 Plot Stokes V NRH source properties
	;	
	; Had a lot of confusion about what convention NRH uses for the sense of polarisation.
	; From Chernov et al. (1998) A&A 334, he describes Stokes V<0 as right-handed (RHCP_. 
	; Right-handed/clockwise rotation having V<0 is from the point of view of the
	; receiver (https://en.wikipedia.org/wiki/Circular_polarization and 
	; https://en.wikipedia.org/wiki/Stokes_parameters). 
	; This is opposite to the IEEE/IAU convention, which would call this 
	; left-handed (LHCP) from the point of view of the source.

	; Either way, the polarisations is -V RHCP from the PoV of the receiver, meaning in a
	; negative magnetic field the radiation is X-mode polarised.

	; Note also that Orfées shows the pulsations as being +V. Either the data is corrupted or, 
	; more than likely, Orfées uses the IEEE standard of defining the poalriation from the 
	; source PoV, meaning it is +V anti-clockwise.


	restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src1_props_hires_si.sav', /verb	
	flux = xy_arcs_struct.flux_density
	restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src1_props_hires_sv.sav', /verb	
	V_flux = xy_arcs_struct.flux_density
	polari = (V_flux/flux)*100.0

	utplot, times, smooth(polari, 2), $
		/xs, $
		/ys, $
		yr = [-80, 0], $
		ytitle='Polarisation (%)', $
		;xtickformat='(A1)', $
  		xtitle = 'Time (UT)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
		position = pos2, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=3	

	restore, '~/Data/2014_apr_18/pulsations/nrh_298_pulse_src1_props_hires_si.sav', /verb	
	flux = xy_arcs_struct.flux_density
	restore, '~/Data/2014_apr_18/pulsations/nrh_298_pulse_src1_props_hires_sv.sav', /verb	
	;times = anytim(xy_arcs_struct.times, /utim)
	V_flux = xy_arcs_struct.flux_density
	polari = (V_flux/flux)*100.0	
	outplot, times, smooth(polari, 2), color=4

	restore, '~/Data/2014_apr_18/pulsations/nrh_327_pulse_src1_props_hires_si.sav', /verb	
	flux = xy_arcs_struct.flux_density
	restore, '~/Data/2014_apr_18/pulsations/nrh_327_pulse_src1_props_hires_sv.sav', /verb	
	;times = anytim(xy_arcs_struct.times, /utim)
	V_flux = xy_arcs_struct.flux_density
	polari = (V_flux/flux)*100.0	
	outplot, times, smooth(polari, 2), color=5
	

if keyword_set(postscript) then device, /close
set_plot, 'x'


stop
END