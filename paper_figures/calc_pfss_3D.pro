pro calc_pfss_3D

    ; Much of this code is borrowed from the standard PFSS package and repurposed for some custom plotting.

    xlines_total = list()
    ylines_total = list()
    zlines_total = list()
    field_strength_total = list()
    rsun = 955.05149  ;arcsec
    @pfss_data_block

	;  first restore the file containing the coronal field model
	pfss_restore, pfss_time2file('2014-04-18T12:00:00', /ssw_cat,/url) 

	;  starting points to be on a regular grid covering the full disk, with a
	invdens = 10.0 ;  factor inverse to line density, i.e. lower values = more lines
	for j=0, 1 do begin
        pfss_field_start_coord, 5, invdens, radstart=1.2

        shif = j
        str = replicate(1.01, 100.)
        stph_range = transpose(interpol([200+shif, 215+shif], 10.)) ;transpose(interpol([215, 230], 10))
        stth_range = interpol([90+shif, 120+shif], 10.)

        for i=0, 9 do begin
            if i eq 0 then begin
            stph = stph_range
            stth = stth_range
            endif else begin
            stph = [ stph, stph_range ]
            stth = [ [stth], [stth_range] ]
            endelse	
        endfor
        stth = stth*!dtor
        stph = stph*!dtor
        junk = execute('pfss_trace_field')
        ;----------------------------------------------;
        ;			Field line plot
        ; 	
        bcent=-5.36
        lcent=216.191 - 2.9e-6*!radeg*60.*60.*6.75	; First number from pfss_viewer, for 06:00 UT on the day. Because the image is at 12:00, multiply by solar angular velocity and 6 hours
        cb=cos(bcent(0)*!dtor)
        sb=-sin(bcent(0)*!dtor)
        rmin=min(rix,max=rmax)
        npt=n_elements(ptr[0, *])
        open=intarr(npt)

        ptr2=ptr
        ptr[*]=1.
        for i=0,npt-1 do begin

            ;  transform from spherical to cartesian coordinates
            ns=nstep(i)
            xp=ptr(0:ns-1,i)*sin(ptth(0:ns-1,i))*sin(ptph(0:ns-1,i)-lcent(0)*!dtor)
            yp=ptr(0:ns-1,i)*sin(ptth(0:ns-1,i))*cos(ptph(0:ns-1,i)-lcent(0)*!dtor)
            zp=ptr(0:ns-1,i)*cos(ptth(0:ns-1,i))

            ;  now latitudinal tilt
            xpp=xp
            ypp=cb*yp-sb*zp
            zpp=sb*yp+cb*zp

            ;  determine whether line is open or closed 
            if (max(ptr(0:ns-1,i))-rmin)/(rmax-rmin) gt 0.99 then begin
                irc=get_interpolation_index(rix,ptr(0,i))
                ithc=get_interpolation_index(lat,90-ptth(0,i)*!radeg)
                iphc=get_interpolation_index(lon,(ptph(0,i)*!radeg+360) mod 360)
                brc=interpolate(br,iphc,ithc,irc)
                if brc gt 0 then open(i)=1 else open(i)=-1
            endif  ;  else open(i)=0, which has already been done

            ;  only plot those lines that go higher than the first radial gridpoint
            heightflag=max(ptr(0:ns-1,i)) gt rix(1)
            ; drawflag=(drawopen and (open(i) ne 0)) or (drawclosed and (open(i) eq 0))

            ;  hide line segments that are behind disk
            wh1=where(ypp ge 0,nwh1)
            wh2=where((ypp lt 0) and ((xpp^2+zpp^2) gt rix(0)^2),nwh2)
            case 1 of
            (nwh1 gt 0) and (nwh2 gt 0): wh=union(wh1,wh2)
            (nwh1 gt 0) and (nwh2 eq 0): wh=wh1
            (nwh1 eq 0) and (nwh2 gt 0): wh=wh2
            (nwh1 eq 0) and (nwh2 eq 0): doline=0
            endcase
            if (nwh1+nwh2) gt 0 then doline=1

            if doline then begin

                ;  select the visible coordinates of the line
                xpp=xpp(wh)
                ypp=ypp(wh)
                zpp=zpp(wh)

                ;  determine color
                case open(i) of
                -1: col=5
                0: if keyword_set(for_ps) then col=0 else col=10
                1: col=4
                endcase
                ;  plot lines
                ;plots,xpp,zpp,ypp,col=col,/t3d,thick=thick
                ;set_line_color
                irc=get_interpolation_index(rix,ptr(0:ns-1,i))
                ithc=get_interpolation_index(lat,90-ptth(0:ns-1,i)*!radeg)
                iphc=get_interpolation_index(lon,(ptph(0:ns-1,i)*!radeg+360) mod 360)
                br_strength = interpolate(br,iphc,ithc,irc)
                bth_strength = interpolate(bth,iphc,ithc,irc)
                bph_strength = interpolate(bph,iphc,ithc,irc)
                field_strength = sqrt(br_strength^2.0 + bth_strength^2.0 + bph_strength^2.0)
                field_strength =  alog10(field_strength)

                xlines = xpp*rsun
                ylines = zpp*rsun
                ;plots, xlines, ylines, col=10, thick=4
                ;plots, xlines, ylines, col=150, thick=3
            endif
      
        endfor

        ptr=ptr2
        colors = findgen(1000)*(255)/999.
        bfields = alog10(findgen(1000)*(1000)/999.)
        ; Following loop same as above. Should wrapped in an outer loop to avoid repetition.
        for i=0,npt-1 do begin

            ;  transform from spherical to cartesian coordinates
            ns=nstep(i)
            xp=ptr(0:ns-1,i)*sin(ptth(0:ns-1,i))*sin(ptph(0:ns-1,i)-lcent(0)*!dtor)
            yp=ptr(0:ns-1,i)*sin(ptth(0:ns-1,i))*cos(ptph(0:ns-1,i)-lcent(0)*!dtor)
            zp=ptr(0:ns-1,i)*cos(ptth(0:ns-1,i))

            ;  now latitudinal tilt
            xpp=xp
            ypp=cb*yp-sb*zp
            zpp=sb*yp+cb*zp
            stop

            ;  determine whether line is open or closed 
            if (max(ptr(0:ns-1,i))-rmin)/(rmax-rmin) gt 0.99 then begin
            irc=get_interpolation_index(rix,ptr(0,i))
            ithc=get_interpolation_index(lat,90-ptth(0,i)*!radeg)
            iphc=get_interpolation_index(lon,(ptph(0,i)*!radeg+360) mod 360)
            brc=interpolate(br,iphc,ithc,irc)
            if brc gt 0 then open(i)=1 else open(i)=-1
            endif  ;  else open(i)=0, which has already been done

            heightflag=max(ptr(0:ns-1,i)) gt rix(1)
            wh1=where(ypp ge 0,nwh1)
            wh2=where((ypp lt 0) and ((xpp^2+zpp^2) gt rix(0)^2),nwh2)
            case 1 of
                (nwh1 gt 0) and (nwh2 gt 0): wh=union(wh1,wh2)
                (nwh1 gt 0) and (nwh2 eq 0): wh=wh1
                (nwh1 eq 0) and (nwh2 gt 0): wh=wh2
                (nwh1 eq 0) and (nwh2 eq 0): doline=0
            endcase
            if (nwh1+nwh2) gt 0 then doline=1

            if doline then begin

                ;  select the visible coordinates of the line
                xpp=xpp(wh)
                ypp=ypp(wh)
                zpp=zpp(wh)

                ;  determine color
                case open(i) of
                    -1: col=5
                    0: if keyword_set(for_ps) then col=0 else col=8
                    1: col=4
                endcase
                ;  plot lines
                ;plots,xpp,zpp,ypp,col=col,/t3d,thick=thick
                stop
                ;set_line_color
                irc=get_interpolation_index(rix,ptr(0:ns-1,i))
                ithc=get_interpolation_index(lat,90-ptth(0:ns-1,i)*!radeg)
                iphc=get_interpolation_index(lon,(ptph(0:ns-1,i)*!radeg+360) mod 360)
                br_strength = interpolate(br,iphc,ithc,irc)
                bth_strength = interpolate(bth,iphc,ithc,irc)
                bph_strength = interpolate(bph,iphc,ithc,irc)
                field_strength = sqrt(br_strength^2.0 + bth_strength^2.0 + bph_strength^2.0)
                field_strength =  alog10(field_strength)

                cols = interpol(colors, bfields, field_strength) 

                xlines = xpp*rsun
                ylines = zpp*rsun
                zlines = ypp*rsun
                for jj=1, n_elements(xlines)-1 do begin 
                    plots, [xlines[jj], xlines[jj-1]]>(-250)<50, [ylines[jj], ylines[jj-1] ]>(-400)<(-100), col=cols[jj], thick=2.5
                endfor  
                xlines_total -> add, xlines
                ylines_total -> add, ylines
                zlines_total -> add, zlines
                field_strength_total -> add, field_strength

            endif

        endfor
    endfor  
    save, br, bph, bth, xlines_total, ylines_total, zlines_total


END    