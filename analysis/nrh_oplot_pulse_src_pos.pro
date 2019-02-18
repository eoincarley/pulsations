pro nrh_oplot_pulse_src_pos, time

	; Simple code to produce images of the pulsations source from 2014-04-18

	restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src_props_hires_si.sav', /verb	
	times = anytim(xy_arcs_struct.times, /utim)
	xarcs = xy_arcs_struct.x_max_fit
	yarcs = xy_arcs_struct.y_max_fit
	mean_x = mean(xarcs)
	mean_y = mean(yarcs)
  
  	index = closest(times, time)
	
  	loadct, 16, /silent
	colors = findgen(n_elements(xarcs))*(255)/(n_elements(xarcs)-1)
	for i=0, n_elements(xarcs)-1 do plots, xarcs[i], yarcs[i], psym=1, color=colors[i], symsize=0.5, thick=1

	;set_line_color
	;plots, xarcs[index], yarcs[index], psym=1, color=0, symsize=3.0, thick=5


	


END