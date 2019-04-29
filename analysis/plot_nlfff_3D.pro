pro plot_nlfff_3D

    ; Code to make the Sun and GCS model. Used to simulate CME brightness.

    loadct, 39
    !p.color=0
    !p.background=255 
    window, 0, xs=900, ys=900, RETAIN=2 
    set_line_color

    rsun_box = 200
    x_range = [0, 500];[0.1, 1.5]
    y_range = [0, 500];[0.1, 1.2]
    z_range = [0, 500]

    
    ;--------------Set up 3D environment-----------------;

    surface, dist(5), /nodata, /save, $
        xrange=x_range, yrange=y_range, zrange=z_range, $
        zstyle=1, charsize=2.5, $
        xtitle='X', ytitle='Y', ztitle ='Z';, $
        ;position = [0.05, 0.1, 0.45, 0.9]

    ;---------------------Plot Axes-----------------------;
    plot_axes

    restore, '~/data/2014_apr_18/pulsations/nlfff_lines_bxbybz.sav'
    for i = 0, n_elements(xlines)-1 do begin
        ;plots, xlines[i], ylines[i], zlines[i], color=5, /t3d, thick=1

        line = [ [xlines[i]], [ylines[i]], [zlines[i]] ]
        strength = [ [bx[i]], [by[i]], [bz[i]] ]
        save, line, strength, filename='~/python/NLFFF/linecoords/NLFF_line_'+string(i, format='(I04)')+'.sav'
    endfor            
   

END

;-----------------------------------------------------------;
;                   END MAIN PROCEDURE
;-----------------------------------------------------------;

pro plot_axes

    create_vector, 1.9, -90, 0.0, x, y, z   ;xaxis
    plots, x, y, z, color=0, thick=1, /t3d
    create_vector, 1.9, 0.0, 0.0, x, y, z   ;yaxis
    plots, x, y, z, color=0, thick=1, /t3d
    create_vector, 1.9, -90.0, 90.0, x, y, z  ;zaxis
    plots, x, y, z, color=0, thick=1, /t3d

END



pro create_vector, r1, t1, p1, x, y, z

    ;--------------------First point at the origin---------------------;
    rorig = 0.0
    theta_orig = 0.0
    phi_orig = 0.0

    x0 = rorig*sin(theta_orig*!dtor)*cos(phi_orig*!dtor)
    y0 = rorig*sin(theta_orig*!dtor)*sin(phi_orig*!dtor)
    z0 = rorig*cos(theta_orig*!dtor);*(-1.0)

    ;-----------------Second point at desired location---------------------;

    x1 = r1*sin(t1*!dtor)*cos(p1*!dtor)
    y1 = r1*sin(t1*!dtor)*sin(p1*!dtor)
    z1 = r1*cos(t1*!dtor);*(-1.0)

    x = [x0,x1]
    y = [y0,y1]
    z = [z0,z1]

END

pro sph_to_cart, r, t, p, x, y, z

END

pro cart_to_spherical, x, y, z, r, t, p

    r = sqrt(x^2.0 + y^2.0 + z^2.0)
    t = acos(z/r)
    p = atan(y/x)

END

function rotation_matrix, x,y,z, angle, axis
        
        ; Perform rotations about 'axis' by angle

        theta = angle*!dtor
        if axis eq 'X' then rot_matrix = [ [1.0, 0.0, 0.0], $
                                           [0.0, cos(theta), -1.0*sin(theta)], $
                                           [0.0, sin(theta), cos(theta)] ]

        if axis eq 'Y' then rot_matrix = [ [cos(theta), 0, sin(theta)], $
                                           [0, 1, 0], $
                                           [-1.0*sin(theta), 0, cos(theta)] ]

        if axis eq 'Z' then rot_matrix = [ [cos(theta), -1.0*sin(theta), 0], $
                                           [sin(theta), cos(theta), 0], $
                                           [0, 0, 1] ]
                                    
        xnew = transpose( x*rot_matrix[0, 0] + y*rot_matrix[1, 0] + z*rot_matrix[2, 0] )
        ynew = transpose( x*rot_matrix[0, 1] + y*rot_matrix[1, 1] + z*rot_matrix[2, 1] )
        znew = transpose( x*rot_matrix[0, 2] + y*rot_matrix[1, 2] + z*rot_matrix[2, 2] )

        return, transpose([[xnew], [ynew], [znew]])

END        






