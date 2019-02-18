pro setup_ps, name
  
  set_plot,'ps'
  !p.font=0
  !p.charsize=0.8
  !p.thick=4
  device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=8, $
          ysize=10, $
          /encapsulate, $
          yoffset=5

end

pro plot_flux, times, flux, pos=pos, color=colour, xtickfmt=xtickfmt

	utplot, times, flux, $
		/xs, $
		/ys, $
		/ylog, $
		ytitle='Flux (SFU)', $
		xtickformat=xtickfmt, $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = ' ', $
  		yr=[0.1, 300], $
		pos = pos, $
		/normal, $
		/noerase, $
		color=colour	

	
END

pro plot_supp_fig_longflux, postscript=postscript

	; Window setup
	if keyword_set(postscript) then begin
        setup_ps, '~/Data/2014_apr_18/pulsations/nrh_flux_long.eps
	endif else begin
		loadct, 0
		window, 0, xs=800, ys=1000, retain=2
		 !p.thick=1
	endelse

	ypos = 0.98
	plot_delt = 0.1
	del_inc = 0.002
	pos0 = [0.1, ypos-plot_delt, 0.93, ypos]
	pos1 = [0.1, ypos-plot_delt*2.0, 0.93, ypos-plot_delt - del_inc]
	pos2 = [0.1, ypos-plot_delt*3.0, 0.93, ypos-plot_delt*2.0- del_inc]
	pos3 = [0.1, ypos-plot_delt*4.0, 0.93, ypos-plot_delt*3.0- del_inc]
	pos4 = [0.1, ypos-plot_delt*5.0, 0.93, ypos-plot_delt*4.0- del_inc]
	pos5 = [0.1, ypos-plot_delt*6.0, 0.93, ypos-plot_delt*5.0- del_inc]
	pos6 = [0.1, ypos-plot_delt*7.0, 0.93, ypos-plot_delt*6.0- del_inc]
	pos7 = [0.1, ypos-plot_delt*8.0, 0.95, ypos-plot_delt*7.0- del_inc]
	pos8 = [0.1, ypos-plot_delt*9.0, 0.95, ypos-plot_delt*8.0- del_inc]
	set_line_color
	folder = '~/data/2014_apr_18/pulsations/long_dur_flux/'
	;-------------------------------------------;
	;	 Plot Stokes I NRH source properties
	;	
	restore, folder+'nrh_150_flux_long_duration.sav', /verb	
	times = anytim(flux_struct.times, /utim)
	flux = smooth(flux_struct.flux_density, 5)
	plot_flux, times, flux, pos=pos0, color=0, xtickfmt='(A1)'
	plot_flux, times, flux, pos=pos0, color=2, xtickfmt='(A1)'

	restore, folder+'nrh_228_flux_long_duration.sav', /verb	
	flux = smooth(flux_struct.flux_density, 5)
	plot_flux, times, flux, pos=pos1, color=7, xtickfmt='(A1)'

	restore, folder+'nrh_298_flux_long_duration.sav', /verb	
	flux = smooth(flux_struct.flux_density, 5)
	plot_flux, times, flux, pos=pos2, color=4, xtickfmt='(A1)'

	restore, folder+'nrh_327_flux_long_duration.sav', /verb	
	flux = smooth(flux_struct.flux_density, 5)
	plot_flux, times, flux, pos=pos3, color=5, xtickfmt='(A1)'

	restore, folder+'nrh_408_flux_long_duration.sav', /verb	
	flux = smooth(flux_struct.flux_density, 5)
	plot_flux, times, flux, pos=pos4, color=6, xtickfmt='(A1)'

	restore, folder+'nrh_445_flux_long_duration.sav', /verb	
	flux = smooth(flux_struct.flux_density, 5)
	plot_flux, times, flux, pos=pos5, color=10, xtickfmt=''


if keyword_set(postscript) then device, /close
set_plot, 'x'
STOP

END