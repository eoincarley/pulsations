pro pulse_B_estimate

	period = 2.0 ; seconds
	freq = 228e6/2.0 ; MHz
	ni = freq_to_dens(freq) ; cm^-3
	ni = 1.61e8	 ; cm^-3
	a = 5100e5	 ; cm
	mp = 1.67e-24 ; g

	B = 2.62*a*sqrt(4.0D*!pi*ni*mp)/period

	print, 'Magnetic field stength (G)'+string(B)

	stop
END