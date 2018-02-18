include <x-carriage.h>

use <x-end.scad>
use <belt_fastener.scad>;
use <fanduct.scad>

use <thing_libutils/shapes.scad>;
use <thing_libutils/misc.scad>;
use <thing_libutils/transforms.scad>;
use <thing_libutils/attach.scad>;
use <thing_libutils/linear-extrusion.scad>;
use <thing_libutils/bearing.scad>
use <thing_libutils/bearing-linear.scad>
use <thing_libutils/screws.scad>
use <thing_libutils/shape_gears.scad>

include <thing_libutils/bearing_data.scad>;
include <thing_libutils/pulley.scad>;
include <thing_libutils/timing-belts.scad>
include <thing_libutils/materials.scad>

module x_extruder_hotend()
{
    material(Mat_Aluminium)
    tz(-21.3*mm)
    rz(-90)
    rx(90)
    import("stl/E3D_V6_1.75mm_Universal_HotEnd_Mockup.stl");

    tz(-hotend_height)
    color("blue")
    spherea(2, align=Z);

    tz(-hotend_height)
    {
        /*fanduct();*/
    }

    //filament path
    material(Mat_PlasticBlack)
    cylindera(h=1000, d=1.75*mm, orient=Z, align=N);
}

module x_extruder_hotend_()
{
    material(Mat_Aluminium)
    import("stl/E3D_V6_1.75mm_Universal_HotEnd_Mockup.stl");

    // official 30mm duct
    /*ty(-22)*/
    /*rotate(180*Y)*/
    /*import("stl/V6.6_Duct.stl");*/

    /*ty(-21.5)*/
    /*rotate(180*Y)*/
    /*import("stl/30mm_Clamp.stl");*/

    /*mirror(Z)*/
    /*tx(10)*/
    /*tx(27)*/
    /*tz(-44)*/
    /*ty(38)*/
    /*rotate(-22*Z)*/
    /*rotate(270*Y)*/
    /*rotate(90*X)*/
    /*import("stl/Radial_Fan_Fang_5015_SN04.stl");*/

    /*mirror(Z)*/
    /*tx(10)*/
    /*tx(37)*/
    /*tz(-43.6)*/
    /*ty(34)*/
    /*rotate(-22*Z)*/
    /*rotate(270*Y)*/
    /*rotate(90*X)*/
    /*import("stl/Radial_Fan_Fang_5015.stl");*/

    /*tx(10) // E3D fan thickness*/
    /*tx(-12.7)*/
    /*ty(22)*/
    /*rotate(90*X)*/
    /*import("stl/Radial_Fan_Fang_5015_mod.stl");*/

    tz(0)
    tx(24.5)
    ty(-7.5)
    ry(90)
    ry(180)
    import("stl/Custom_E3D_V6_40mm_Fan_V2.stl");

    tt = 10*mm; // E3D fan thickness

    tx(tt)
    tx(-5.7)
    ty(28)
    rx(90)
    import("extras/Fang_5015_40mm_v4 - Copy.stl");

    // E3D fan
    tx(7.2)
    tx(tt)
    tx(12.5*mm)
    ty(-6*mm)
    {
        d=40*mm;
        difference()
        {
            cubea([tt,d,d]);
            cylindera(d=d-5*mm, h=1000, orient=X);

            for(x=[-1,1])
            for(y=[-1,1])
            tz(x*(d/2 - 3.5*mm))
            ty(y*(d/2 - 3.5*mm))
            screw_cut(thread=extruder_hotend_clamp_thread, h=12*mm, orient=-X, align=-X);
        }
    }

    /*tx(25)*/
    /*ty(-7)*/
    /*rotate(-90*Y)*/
    /*import("stl/Custom_E3D_V6_40mm_Fan_V2.stl");*/

    /*[>tx(10)<]*/
    /*tx(22)*/
    /*tz(-56)*/
    /*ty(49)*/
    /*rotate(-22*Z)*/
    /*rotate(90*X)*/
    /*import("stl/Radial_Fan_Fang_5015_for_40mm_thicker.stl");*/

}

module x_carriage(part=undef, beltpath_sign=1)
{
    if(part==undef)
    {
        difference()
        {
            x_carriage(part="pos");
            x_carriage(part="neg");
        }
    }
    else if(part=="pos")
    material(Mat_Plastic)
    {
        hull()
        {
            // top bearings
            translate([0,0,xaxis_rod_distance/2])
            rcubea([xaxis_carriage_top_width, xaxis_carriage_thickness, xaxis_bearing_top_OD+xaxis_carriage_padding+ziptie_bearing_distance*2], align=Y);

            /*rcubea([xaxis_carriage_top_width,xaxis_carriage_thickness,xaxis_rod_distance/2], align=Y);*/

            // bottom bearing
            translate([0,0,-xaxis_rod_distance/2])
            rcubea([xaxis_carriage_bottom_width, xaxis_carriage_thickness, xaxis_bearing_bottom_OD+xaxis_carriage_padding+ziptie_bearing_distance*2], align=Y);

            /// support for extruder mount
            translate(extruder_offset)
            position(extruder_b_mount_offsets)
            rcylindera(r=4*mm, align=Y, orient=Y);

            // extruder A mount
            translate(extruder_offset)
            translate(extruder_offset_a)
            ty(-extruder_offset_a[1])
            rotate([0,extruder_motor_mount_angle,0])
            position(extruder_a_mount_offsets)
            rcylindera(d=extruder_b_mount_dia, h=xaxis_carriage_thickness, orient=Y, align=Y);

            for(z=xaxis_beltpath_z_offsets)
            translate([0, xaxis_carriage_beltpath_offset_y, z])
            mirror([0,0,sign(z)<1?1:0])
            mirror(X)
            {
                proj_extrude_axis(axis=Y, offset=xaxis_carriage_beltpath_offset_y)
                belt_fastener(
                   part=part,
                   width=55*mm,
                   belt=xaxis_belt,
                   belt_width=xaxis_belt_width,
                   belt_dist=xaxis_pulley_inner_d,
                   thick=xaxis_carriage_thickness,
                   with_tensioner=beltpath_sign==sign(z)
                   );
            }
        }

        // endstop bumper for physical switch endstop
        translate([0,xaxis_carriage_beltpath_offset_y,0])
        if(xaxis_endstop_type == "SWITCH")
        {
            translate([-xaxis_carriage_top_width/2,0,xaxis_end_wz/2])
            rcubea(size=xaxis_endstop_size_switch, align=ZAXIS+XAXIS, extra_size=Y*(xaxis_carriage_beltpath_offset_y-xaxis_endstop_size_switch.y/2), extra_align=-Y);
        }
        else if(xaxis_endstop_type == "SN04")
        {
            translate(xaxis_endstop_SN04_pos)
            /*proj_extrude_axis(axis=Y, offset=xaxis_carriage_beltpath_offset_y)*/
            rcylindera(d=12*mm, h=20*mm, orient=XAXIS, align=XAXIS);
        }
    }
    else if(part=="neg")
    {
        for(z=xaxis_beltpath_z_offsets)
        translate([0, xaxis_carriage_beltpath_offset_y, z])
        mirror([0,0,sign(z)<1?1:0])
        mirror(X)
        {
            belt_fastener(
               part=part,
               width=55*mm,
               belt=xaxis_belt,
               belt_width=xaxis_belt_width,
               belt_dist=xaxis_pulley_inner_d,
               thick=xaxis_carriage_thickness,
               with_tensioner=beltpath_sign==sign(z)
               );
        }
    }
    else if(part=="vit")
    {
    }

    // bearing mount top
    for(x=spread(-xaxis_carriage_bearing_distance/2,xaxis_carriage_bearing_distance/2,xaxis_bearings_top))
    translate([x,xaxis_bearing_top_OD/2+xaxis_carriage_bearing_offset_y,xaxis_rod_distance/2])
    linear_bearing_mount(part=part, bearing=xaxis_bearing_top, ziptie_type=ziptie_type, ziptie_bearing_distance=ziptie_bearing_distance, orient=X, align=-sign(x)*X, mount_dir_align=Y);

    // bearing mount bottom
    /*tx(-20)*/
    for(x=spread(-xaxis_carriage_bearing_distance/2,xaxis_carriage_bearing_distance/2,xaxis_bearings_bottom))
    translate([x,xaxis_bearing_bottom_OD/2+xaxis_carriage_bearing_offset_y,-xaxis_rod_distance/2])
    linear_bearing_mount(part=part, bearing=xaxis_bearing_bottom, ziptie_type=ziptie_type, ziptie_bearing_distance=ziptie_bearing_distance, orient=X, align=-sign(x)*X, mount_dir_align=Y);
}

module extruder_gear_small(orient, align)
{
    material(Mat_Steel)
    difference()
    {
        union()
        {
            ty(-6*mm)
            {
                h=7*mm;
                if($preview_mode)
                {
                    cylindera(d=extruder_gear_small_PD, h=h, orient=orient, align=align);
                }
                else
                {
                    rx(90)
                    tz(h/2)
                    gear(z=get(GearTeeth, extruder_gear_small), m=get(GearMod, extruder_gear_small), h=h);
                }
            }
            h=13*mm;

            cylindera(d=extruder_gear_small_PD, h=h-7*mm, orient=orient, align=align);
        }
        cylindera(d=5*mm, h=13*mm+.1, orient=orient, align=align);
    }
}


module extruder_gear_big(align=N, orient=Z)
{
    total_h = extruder_gear_big_h[0]+extruder_gear_big_h[1];
    material(Mat_Steel)
    size_align([extruder_gear_big_PD, extruder_gear_big_PD, total_h], align=align, orient=orient, orient_ref=Z)
    translate([0,0,-extruder_gear_big_h[0] + total_h/2])
    difference()
    {
        union()
        {
            if($preview_mode)
            {
                cylindera(d=extruder_gear_big_PD, h=extruder_gear_big_h[0], orient=Z, align=Z);
            }
            else
            {
                tz(extruder_gear_big_h[0]/2)
                gear(z=get(GearTeeth, extruder_gear_big), m=get(GearMod, extruder_gear_big),h=extruder_gear_big_h[0]);
            }

            cylindera(d=12*mm, h=extruder_gear_big_h[1], orient=Z, align=[0,0,-1]);
        }
        translate([0,0,-.5])
        cylindera(d=5*mm, h=total_h+.2, orient=Z, align=N);
    }
}


module extruder_a_motor_mount(part)
{
    motor_thread=ThreadM3;
    motor_nut=NutHexM3;

    if(part=="pos")
    material(Mat_Plastic)
    ry(extruder_motor_mount_angle)
    {
        // mounts
        position(extruder_a_mount_offsets)
        rcylindera(d=extruder_b_mount_dia, h=extruder_a_h, orient=Y, align=Y);

        // motor mounts support
        // screws for mounting motor
        hull()
        ty(extruder_a_h)
        for(x=[-1,1])
        for(z=[-1,1])
        tx(x*extruder_motor_holedist/2)
        tz(z*extruder_motor_holedist/2)
        rcylindera(d=get(ThreadSize, motor_thread)+6*mm, h=extruder_a_base_h, orient=Y, align=-Y);
    }
    else if(part=="neg")
    ry(extruder_motor_mount_angle)
    {
        // round dia
        translate([0,extruder_a_h,0])
        translate([0, .1, 0])
        {
            cylindera(h=2*mm, d=1.1*lookup(NemaRoundExtrusionDiameter, extruder_motor), orient=Y, align=[0,-1,0]);

            ty(-(2*mm-0.01))
            cylindera(h=extruder_a_h/2, d1=1.1*lookup(NemaRoundExtrusionDiameter, extruder_motor), d2=lookup(NemaRoundExtrusionDiameter, extruder_motor)*mm/1.5, orient=-Y, align=-Y);

            translate([0,-2*mm+.1-extruder_a_h/2+.1,0])
            cylindera(d=0.5*lookup(NemaRoundExtrusionDiameter, extruder_motor), h=extruder_a_h/2, orient=Y, align=[0,-1,0]);

            // motor axle
            cylindera(d=1.2*lookup(NemaAxleDiameter, extruder_motor), h=lookup(NemaFrontAxleLength, extruder_motor)+2*mm, orient=Y, align=[0,-1,0]);
        }

        position(extruder_a_mount_offsets)
        screw_cut(nut=NutKnurlM3_3_42, h=6*mm, with_nut=false, head_embed=false, orient=Y, align=Y);

        // screws for mounting motor
        ty(-3*mm)
        ty(extruder_a_h)
        for(x=[-1,1])
        for(z=[-1,1])
        tx(x*extruder_motor_holedist/2)
        tz(z*extruder_motor_holedist/2)
        screw_cut(nut=motor_nut, h=6*mm, with_nut=false, head_embed=false, orient=Y, align=Y);
    }
    else if(part=="vit")
    {
    }
}

module extruder_a(part=undef)
{
    between_bearing_and_gear=0*mm;
    if(part==undef)
    {
        difference()
        {
            extruder_a(part="pos");
            extruder_a(part="neg");
        }
        if($show_vit)
        %extruder_a(part="vit");
    }
    else if(part=="pos")
    material(Mat_Plastic)
    {
        /*hull()*/
        {
            // create a base plate
            hull()
            {
                intersection()
                {
                    extruder_a_motor_mount(part=part);
                    translate([0,extruder_a_h,0])
                    cubea(size=[1000,extruder_a_base_h,1000], align=-Y);
                }
                // support around bearing
                translate([0,extruder_a_h,0])
                translate(extruder_gear_big_offset)
                rcylindera(d=extruder_a_bearing[1]+6*mm, h=extruder_a_base_h, orient=Y, align=-Y);
            }

            extruder_a_motor_mount(part=part);

            // support round big gear, needed?
            /*translate(extruder_gear_big_offset)*/
            /*rcylindera(d=extruder_gear_big_OD+2*mm+5*mm, h=extruder_a_h, orient=Y, align=Y);*/

        }
    }
    else if(part=="neg")
    {
        extruder_a_motor_mount(part=part);

        //cutouts for access to small gear tightscrew
        /*rotate([0,extruder_motor_mount_angle,0])*/
        /*for(i=[-1,10])*/
        /*rotate([0,i*90,0])*/
        /*translate([0,0,lookup(NemaSideSize, extruder_motor)/2])*/
        /*translate([0,extruder_a_h,0])*/
        /*teardrop(d=17*mm, h=lookup(NemaSideSize, extruder_motor)/2, orient=Z, roll=90, align=[0,0,-1]);*/

        //cutouts for access to big gear tightscrew
        /*translate(extruder_gear_big_offset)*/
        /*translate([0,extruder_gear_big_h[0],0])*/
        /*translate([1,extruder_gear_big_h[1]/2+1*mm,0])*/
        /*for(i=[0:6])*/
        /*rotate([0,20+i*-35,0])*/
        /*teardrop(d=9*mm, h=1000, orient=X, align=[-1,0,0], roll=90);*/

        translate([0,extruder_a_h,0])
        {
            translate([0,-extruder_gear_motor_dist,0])
            translate(extruder_gear_big_offset)
            {
                // big gear cutout
                translate([0,-between_bearing_and_gear,0])
                translate([0,-extruder_a_bearing[2],0])
                {
                    cylindera(d=extruder_gear_big_OD+2*mm, h=extruder_a_h+.2, orient=Y, align=[0,-1,0]);
                }

                cylindera(d=extruder_shaft_d+1*mm, h=extruder_a_h+.2, orient=Y, align=[0,-1,0]);

                translate(extruder_a_bearing_offset_y)
                scale(1.02)
                cylindera(d=extruder_a_bearing[1], h=1000*mm, orient=Y, align=[0,-1,0]);
            }
        }
    }
    else if(part=="vit")
    {
        extruder_a_motor_mount(part=part);

        translate([0,extruder_a_h,0])
        {
            translate([0,-extruder_gear_motor_dist,0])
            {
                ty(-.5*mm)
                extruder_gear_small(orient=Y, align=-Y);

                // big gear
                translate(extruder_gear_big_offset)
                {
                    translate([0,-between_bearing_and_gear,0])
                    translate([0,-extruder_a_bearing[2],0])
                    ty(-1*mm)
                    extruder_gear_big(orient=-Y, align=-Y);

                    // bearing
                    translate(extruder_a_bearing_offset_y)
                    bearing(extruder_a_bearing, orient=Y, align=[0,-1,0]);

                    cylindera(h=extruder_shaft_len, d=extruder_shaft_d, orient=Y, align=[0,-1,0]);
                }
            }
            rotate([0,extruder_motor_mount_angle,0])
            {
                translate([0,-1*mm,0])
                {
                    motor(extruder_motor, NemaMedium, dualAxis=false, orientation=[-90,0,0]);

                    // motor heatsink
                    translate([0,lookup(NemaLengthMedium, extruder_motor)+2*mm,0])
                    {
                        w = lookup(NemaSideSize, extruder_motor);
                        if(false)
                        color([.5,.5,.5])
                        cubea([40*mm,11*mm,40*mm], align=Y);

                        // fan
                        if(false)
                        color([.9,.9,.9])
                        translate([0,11*mm,0])
                        {
                            difference()
                            {
                                cubea([40*mm,10*mm,40*mm], align=Y);
                                cylindera(d=38*mm, h=10*mm+.1, orient=Y, align=[0,-1,0]);
                            }

                        }
                    }

                }

            }

        }
    }
}

module hotend_cut(extend_cut=false, extend_cut_amount = 1000)
{
    // cutout of j-head/e3d heatsink mount
    heights=vec_i(hotend_d_h,1);
    for(e=v_itrlen(hotend_d_h))
    {
        hs=v_sum(heights,e);
        translate([0,0,-hs])
        {
            d=hotend_d_h[e][0]+hotend_tolerance;
            h=hotend_d_h[e][1]+hotend_tolerance;
            cylindera(d=d,h=h,align=Z);
            if(extend_cut)
            {
                cubea([d, extend_cut_amount, h], align=-Y+Z);
            }
        }
    }
}

module extruder_b_filaguide(part)
{
    base_thick = 2*mm;
    base_s=[hotend_outer_size_xy-5*mm, hotend_outer_size_xy, base_thick];

    if(part==undef)
    {
        difference()
        {
            extruder_b_filaguide(part="pos");
            extruder_b_filaguide(part="neg");

            t(-extruder_b_hotend_mount_offset)
            attach(extruder_conn_guidler, guidler_conn, $explode=0)
            extruder_guidler(part="guidecut", $show_vit=false);
        }
        if($show_vit)
        %extruder_b_filaguide(part="vit");
    }
    else if(part=="pos")
    material(Mat_Plastic)
    {
        // base
        tz(.1*mm)
        cubea(base_s, align=Z);

        // outer tube/support
        tz(.1*mm)
        rcylindera(d=extruder_filaguide_d, h=-extruder_b_hotend_mount_offset.z, orient=Z, align=Z);

        hull()
        {
            // base
            tz(.1*mm)
            cubea([extruder_filaguide_d, hotend_outer_size_xy/2, base_thick], align=Z-Y);

            // outer tube/support
            tz(.1*mm)
            rcylindera(d=extruder_filaguide_d, h=-extruder_b_hotend_mount_offset.z, orient=Z, align=Z);
        }
    }
    else if(part=="neg")
    {
        // cut for filament at top
        pcylindera(d=filament_d+.25*mm, h=guidler_w, orient=Z, align=Z, extra_h=1*mm);

        // cut for ptfe tube
        pcylindera(d=extruder_ptfe_tube_d, h=-extruder_b_hotend_mount_offset.z-7*mm, orient=Z, align=Z);
    }
    else if(part=="support")
    {
        // filaguide base support
        tz(.1*mm)
        rcubea(base_s+[3*mm, 0, 1.5*mm], align=Z);
    }
    else if(part=="cutout")
    {
        tolerance = .4*mm;
        // base
        proj_extrude_axis(axis=-Y, offset=extruder_b_hotend_mount_offset.y)
        scale(1.01)
        r(X*180)
        tz(.1*mm)
        cubea(base_s+[tolerance,tolerance,tolerance], align=Z);

        // outer tube/support
        proj_extrude_axis(axis=-Y, offset=extruder_b_hotend_mount_offset.y)
        scale(1.01)
        r(X*180)
        tz(.1*mm)
        ty(-.1*mm)
        rcylindera(d=extruder_ptfe_tube_d+3*mm+.1*mm, h=-extruder_b_hotend_mount_offset.z, orient=Z, align=Z);
    }
}

module extruder_b(part=undef)
{
    if(part==undef)
    {
        difference()
        {
            extruder_b(part="pos");
            extruder_b(part="neg");

            t(extruder_offset_c)
            extruder_c(part="neg", $show_vit=false);

            attach(extruder_conn_guidler, guidler_conn, $explode=0)
            extruder_guidler(part="neg", $show_vit=false);
        }
        if($show_vit)
        %extruder_b(part="vit");
    }
    else if(part=="pos")
    material(Mat_Plastic)
    {
        /*proj_extrude_axis_part(axis=Y, offset=5*mm)*/
        hull()
        {
            position(extruder_b_mount_offsets)
            rcylindera(d=extruder_b_mount_dia, h=extruder_b_thick, orient=Y, align=-Y);

            // guidler mount
            txz(extruder_b_guidler_mount_off)
            rcylindera(d=guidler_mount_d, h=extruder_b_guidler_mount_w, orient=Y, align=-Y);

            // guidler screw support
            txz(extruder_b_guidler_screw_offset)
            {
                d = guidler_screw_thread_dia + 3*mm;

                rcubea([d, extruder_b_thick, d], align=-Y);
            }
        }

        // filaguide slot and hotend support
        hull()
        {
            for(x=[-1,1])
            tx(x*hotend_clamp_screws_dist)
            t(extruder_b_hotend_mount_offset)
            t(extruder_b_hotend_clamp_offset)
            ty(-hotend_outer_size_xy/2)
            rcylindera(d=get(ThreadSize, extruder_hotend_clamp_thread)+8*mm, h=extruder_b_thick, orient=Y, align=Y);

            t(extruder_b_hotend_mount_offset)
            extruder_b_filaguide(part="support");
        }
    }
    else if(part=="neg")
    {
        // drive gear window cutout
        t(extruder_b_drivegear_offset)
        ty(extruder_drivegear_drivepath_offset)
        /*[>tx(-extruder_drivegear_d_inner)<]*/
        {
            s=[100,extruder_drivegear_h+1*mm,extruder_drivegear_d_inner+3*mm];
            cubea(s, align=-X);
        }

        t(extruder_b_hotend_mount_offset)
        extruder_b_filaguide(part="cutout");

        guidler_w_cut = guidler_w+.2*mm;

        t(extruder_b_guidler_screw_offset)
        tx(3*mm)
        ty(guidler_w_cut/2)
        cubea([100,100,20*mm], align=X-Y);

        attach(extruder_conn_guidler, N, $explode=0)
        ty(-guidler_w/2)
        ty(guidler_w_cut/2)
        {
            guidler_mount_d_ = guidler_mount_d+1*mm;
            cylindera(d=guidler_mount_d_, h=100, orient=Y, align=-Y);

            hull()
            {
                txz(-guidler_mount_off)
                cylindera(d=extruder_drivegear_bearing_d+2*mm, h=100, orient=Y, align=N-Y);

                cylindera(d=guidler_mount_d_, h=100, orient=Y, align=N-Y);

                t(-guidler_mount_off)
                tz(5*mm)
                ty(-100/2)
                extruder_guidler(part="mainblock", override_w=100);
            }

            guidler_pivot_r_bearing = pythag_hyp(
                abs(guidler_mount_off.x),
                abs(guidler_mount_off.z))+(extruder_drivegear_bearing_d)/2+0*mm;

            // cutout pivot to make sure guidler bearing/drivegear can rotate out
            ty(-100)
            pie_slice(guidler_pivot_r_bearing, 90+120, 90+270, 100, orient=Y);

            guidler_pivot_r_mount = pythag_hyp(
                abs(guidler_mount_off.x),
                abs(guidler_mount_off.z))+(extruder_drivegear_bearing_d)/2+(guidler_mount_d_)/2;

            // cutout pivot to make sure guidler bearing/drivegear can rotate out
            ty(-100)
            tz(-guidler_mount_d_/2)
            pie_slice(guidler_pivot_r_mount, 90+145, 90+270, 100, orient=Y);
        }

        // guidler mount screw
        translate(extruder_b_guidler_mount_off)
        cylindera(d=get(ThreadSize, guidler_screw_thread), h=extruder_b_guidler_mount_w+.1, orient=Y);

        // cutout for hobbed gear (inner)
        txz(extruder_b_drivegear_offset)
        cylindera(
                h=abs(extruder_b_drivegear_offset[1])+extruder_drivegear_h+1.1*mm,
                d=extruder_drivegear_d_outer+1.5*mm,
                orient=Y,
                align=-Y
                );

        // filament path
        translate(extruder_b_filapath_offset)
        {
            pcylindera(h=1000, d=filament_d+.7*mm, orient=Z, align=Z);

            tz(extruder_drivegear_d_inner/2+3*mm)
            pcylindera(h=1000, d=extruder_ptfe_tube_d, orient=Z, align=Z);
        }

        // drive gear cutout
        translate(extruder_b_drivegear_offset)
        translate([0,-extruder_drivegear_h/2+1*mm,0])
        cylindera(h=abs(extruder_b_drivegear_offset[1])+extruder_drivegear_h/2+extruder_b_bearing[2]+1*mm, d=extruder_b_bearing[1]+.1*mm, orient=Y, align=Y);

        translate(extruder_b_hotend_mount_offset)
        hotend_cut(extend_cut = true);
    }
    else if(part=="vit")
    {
        /*// debug to ensure sensor/hotend positions are correct*/
        /*if(false)*/
        tz(-hotend_height)
        t(extruder_b_hotend_mount_offset)
        {
            cylindera(h=10, d=filament_d, align=-Z);

            translate(sensormount_sensor_hotend_offset)
            cylindera(h=10, d=filament_d, align=-Z);
        }

        material(Mat_Steel)
        translate(extruder_b_drivegear_offset)
        extruder_drivegear();

        /*ty(.1)*/
        /*bearing(extruder_b_bearing, orient=Y, align=-Y);*/

        material(Mat_PlasticBlack)
        translate(extruder_b_filapath_offset)
        cylindera(h=1000, d=filament_d, orient=Z, align=N);
    }
}

module extruder_drivegear(part)
{
    if(extruder_drivegear_type=="Bondtech")
    extruder_drivegear_bondtech(part);

    if(extruder_drivegear_type=="MK8")
    extruder_drivegear_mk8(part);
}

module extruder_drivegear_bondtech(part)
{
    extruder_drivegear_drivepath_h = 2.4*mm;

    inner_d=extruder_drivegear_d_inner;
    outer_d=8*mm;

    inner_d_gear=7.45;
    outer_d_gear=extruder_drivegear_d_outer;

    gear_h = 4.1*mm;
    gear_offset=9.45;

    if(part==U)
    {
        difference()
        {
            extruder_drivegear_bondtech(part="pos");
            extruder_drivegear_bondtech(part="neg");
        }
        if($show_vit)
        %extruder_drivegear_bondtech(part="vit");
    }
    else if(part=="pos")
    material(Mat_Steel)
    {
        // main gear body
        ty(-extruder_drivegear_drivepath_offset)
        cylindera(h=extruder_drivegear_h, d=outer_d, orient=Y, align=Y);

        // gear teeth
        ty(-extruder_drivegear_drivepath_offset)
        ty(gear_offset)
        {

            ty(gear_h/2)
            rx(90)
            gear(z=17, m=0.5, h=gear_h);
        }

        /*translate([0,-extruder_drivegear_drivepath_h/2,0])*/
        /*cylindera(h=extruder_drivegear_h-extruder_drivegear_h/2+extruder_drivegear_drivepath_offset/2-extruder_drivegear_drivepath_h/2-extruder_drivegear_drivepath_h, d=extruder_drivegear_d_outer, orient=Y, align=-Y);*/
    }
    else if(part=="cutout")
    {
        cylindera(h=1000, d=extruder_drivegear_d_outer, orient=Y, align=N);
    }
    else if(part=="neg")
    material(Mat_Steel)
    {
        cylindera(d=5.01*mm, h=100, orient=N);

        // drive path teeth
        torus($fn=32, d=outer_d+extruder_drivegear_drivepath_h/1.5, radial_width=extruder_drivegear_drivepath_h/2, orient=Y);
    }
    else if(part=="vit")
    {
        material(Mat_Steel)
        ty(-extruder_drivegear_drivepath_offset)
        cylindera(h=gear_h, d=inner_d, orient=Y, align=Y);
    }
}

module extruder_drivegear_mk8(part)
{
    extruder_drivegear_drivepath_h = 3.45;
    if(part==U)
    {
        difference()
        {
            extruder_drivegear_mk8(part="pos");
            extruder_drivegear_mk8(part="neg");
        }
    }
    else if(part=="pos")
    material(Mat_Steel)
    {
        difference()
        {
            cylindera(h=extruder_drivegear_drivepath_h, d=extruder_drivegear_d_outer, orient=Y, align=N);
            torus($fn=32, d=extruder_drivegear_d_outer+extruder_drivegear_drivepath_h/1.5, radial_width=extruder_drivegear_drivepath_h/2, orient=Y);
            /*cylindera(h=extruder_drivegear_drivepath_h, d=extruder_drivegear_d_inner, orient=Y, align=N);*/
        }

        translate([0,extruder_drivegear_drivepath_h/2,0])
        cylindera(h=extruder_drivegear_h/2+extruder_drivegear_drivepath_offset/2-extruder_drivegear_drivepath_h/2, d=extruder_drivegear_d_outer, orient=Y, align=Y);

        translate([0,-extruder_drivegear_drivepath_h/2,0])
        cylindera(h=extruder_drivegear_h-extruder_drivegear_h/2+extruder_drivegear_drivepath_offset/2-extruder_drivegear_drivepath_h/2-extruder_drivegear_drivepath_h, d=extruder_drivegear_d_outer, orient=Y, align=-Y);
    }
    else if(part=="cutout")
    {
        cylindera(h=1000, d=extruder_drivegear_d_outer, orient=Y, align=N);
    }
    else if(part=="neg")
    {
        cylindera(d=5.01*mm, h=100, orient=Y);
    }
}

module extruder_c(part=undef)
{
    if(part==undef)
    {
        difference()
        {
            extruder_c(part="pos");
            extruder_c(part="neg");
        }
        if($show_vit)
        %extruder_c(part="vit");
    }
    else if(part=="pos")
    material(Mat_Plastic)
    {
        hull()
        {
            // hobbed gear bearing support
            rcylindera(d=extruder_b_bearing[1]+8*mm, h=extruder_c_thickness, orient=Y, align=-Y);

            // mount onto extruder B
            position(extruder_c_mount_offsets)
            rcylindera(d=extruder_b_mount_dia, h=extruder_c_thickness, orient=Y, align=-Y);

            /*// hotend clamp screws*/
            /*t(extruder_c_hotend_clamp_offset)*/
            /*for(x=[-1,1])*/
            /*tx(x*hotend_clamp_screws_dist)*/
            /*rcylindera(d=get(ThreadSize, extruder_hotend_clamp_thread)+8*mm, h=extruder_c_thickness, orient=Y, align=-Y);*/

            // guidler mount screw hole
            tx(extruder_b_guidler_mount_off.x)
            tz(guidler_mount_off.z)
            rcylindera(d=guidler_mount_d, h=extruder_c_thickness, orient=Y, align=-Y);
            /*screw_cut(thread=guidler_screw_thread, h=hotend_clamp_screw_l, orient=Y, align=Y);*/
        }

        t(extruder_c_hotend_mount_offset)
        t(extruder_c_hotend_clamp_offset)
        cubea([hotend_clamp_screws_dist-.5*mm,hotend_outer_size_xy/2,extruder_b_mount_dia], align=Y);

    }
    else if(part=="neg")
    {
        // b bearing cutout
        ty(.1)
        cylindera(d=extruder_b_bearing[1]+.3*mm, h=extruder_b_bearing[2]+.5*mm, orient=Y, align=-Y);

        /*// guidler mount screw cut*/
        /*translate(extruder_b_bearing[2]/2*Y)*/
        /*translate(extruder_b_guidler_mount_off)*/
        /*ty(-extruder_c_thickness)*/
        /*screw_cut(nut=guidler_screw_nut, h=extruder_b_guidler_mount_w+extruder_c_thickness+5*mm, orient=Y, align=Y);*/

        t(extruder_c_hotend_mount_offset)
        ty(2*mm)
        hotend_cut(extend_cut = false);

        // mount screws
        ty(-extruder_c_thickness)
        position(extruder_c_mount_offsets)
        screw_cut(thread=extruder_hotend_clamp_thread, h=hotend_clamp_screw_l, nut_offset=0*mm, head_embed=false, orient=Y, align=Y);

        // guidler mount screw hole
        tx(extruder_b_guidler_mount_off.x)
        tz(guidler_mount_off.z)
        ty(-extruder_c_thickness)
        screw_cut(thread=guidler_screw_thread, h=hotend_clamp_screw_l, orient=Y, align=Y);
    }
    else if(part=="vit")
    {
        ty(.1)
        bearing(extruder_b_bearing, orient=Y, align=-Y);

        material(Mat_PlasticBlack)
        translate(extruder_c_filapath_offset)
        cylindera(h=1000, d=filament_d, orient=Z, align=N);
    }
}

// Final part
module x_carriage_withmounts(part, beltpath_sign, with_sensormount)
{
    if(part==undef)
    {
        difference()
        {
            x_carriage_withmounts(part="pos", beltpath_sign=beltpath_sign, with_sensormount=with_sensormount);
            x_carriage_withmounts(part="neg", beltpath_sign=beltpath_sign, with_sensormount=with_sensormount);
        }
        if($show_vit)
        %x_carriage_withmounts(part="vit", beltpath_sign=beltpath_sign, with_sensormount=with_sensormount);
    }
    else if(part=="pos")
    {
        /*hull()*/
        /*union()*/
        {
            x_carriage(part=part, beltpath_sign=beltpath_sign);

            if(with_sensormount)
            t(extruder_offset)
            attach(extruder_carriage_sensormount_conn, sensormount_conn, $explode=false)
            {
                sensormount(part, align=-Y);
            }

            // extruder A mount
            material(Mat_Plastic)
            translate(extruder_offset)
            translate(extruder_offset_a)
            {
                rotate([0,extruder_motor_mount_angle,0])
                position(extruder_a_mount_offsets)
                rcylindera(d=extruder_b_mount_dia, h=extruder_offset_a[1], orient=Y, align=[0,-1,0]);
            }
        }
    }
    else if(part=="neg")
    {
        x_carriage(part=part, beltpath_sign=beltpath_sign);

        // rod between extruder part A and B
        translate(extruder_offset)
        {
            cylindera(h=100*mm, d=extruder_shaft_d+5*mm, orient=Y, align=N);
        }

        // extruder A mount cutout
        translate(extruder_offset)
        translate(extruder_offset_a)
        translate(-[0,extruder_offset_a[1],0])
        rotate([0,extruder_motor_mount_angle,0])
        position(extruder_a_mount_offsets)
        translate([0,.1,0])
        screw_cut(
            nut=NutHexM3,
            h=extruder_offset_a[1]+.2,
            head_embed=true,
            with_nut=false,
            orient=Y,
            align=Y
            );

        // extruder B mount cutout
        translate(extruder_offset)
        position(extruder_b_mount_offsets)
        screw_cut(
            nut=NutKnurlM3_3_42,
            h=4*mm,
            nut_offset=0,
            with_nut_access=false,
            head_embed=false,
            orient=Y, align=Y);

        // endstop bumper for physical switch endstop
        translate([0,xaxis_carriage_beltpath_offset_y,0])
        if(xaxis_endstop_type == "SWITCH")
        {
        }
        else if(xaxis_endstop_type == "SN04")
        {
            translate(xaxis_endstop_SN04_pos)
            screw_cut(nut=NutHexM5, h=10*mm, head_embed=true, with_nut=false, orient=X, align=X);
        }

        if(with_sensormount)
        t(extruder_offset)
        attach(extruder_carriage_sensormount_conn, sensormount_conn)
        {
            sensormount(part, align=-Y);
        }
    }
    else if(part=="vit")
    {
        x_carriage(part=part, beltpath_sign=beltpath_sign);

        if(with_sensormount)
        t(extruder_offset)
        attach(extruder_carriage_sensormount_conn, sensormount_conn)
        {
            sensormount(part, align=-Y);
        }
    }
}

module extruder_guidler(part, override_w)
{
    // for tolerance/fit
    guidler_w_ = fallback(override_w, guidler_w -.5*mm);

    if(part==undef)
    {
        difference()
        {
            extruder_guidler(part="pos");
            extruder_guidler(part="neg");

            t(guidler_mount_off)
            t(-extruder_b_guidler_mount_off)
            t(extruder_offset_b)
            t(extruder_offset_c)
            ty(guidler_w/2)
            extruder_c(part="neg", $show_vit=false);
        }
        if($show_vit)
        %extruder_guidler(part="vit");
    }
    else if(part=="mainblock")
    {
        // guidler main block
        t(guidler_mount_off)
        tx(guidler_mount_d/2)
        tz(guidler_mount_d)
        rcubea([guidler_d, guidler_w_, 15*mm], align=-X, extrasize=guidler_extra_h_up*Z, extrasize_align=Z);
    }
    else if(part=="pos")
    material(Mat_Plastic)
    {
        union()
        {
            guidler_x_2 = guidler_mount_off[1]-guidler_mount_d/2;

            hull()
            {
                extruder_guidler(part="mainblock");

                // guidler bearing bolt/screw support
                t(guidler_drivegear_offset)
                rcylindera(d=extruder_drivegear_bearing_id+1.5*mm,h=guidler_w_, orient=Y);

                /*// filament guide*/
                /*tx(-extruder_drivegear_bearing_d/2)*/
                /*tx(-filament_d/2)*/
                /*tz(extruder_drivegear_bearing_d/2)*/
                /*tz(6*mm)*/
                /*rcylindera(d=filament_d*2, h = 8*mm, align=-Z);*/
            }

            hull()
            {
                extruder_guidler(part="mainblock");

                // guidler bearing/drivegear bolt/screw support
                t(guidler_drivegear_offset)
                rcylindera(d=extruder_drivegear_bearing_id+3*mm, h=guidler_w_, orient=Y);

                // guidler mount point
                translate(guidler_mount_off)
                rcylindera(d=guidler_mount_d, h=guidler_w_, orient=Y);
            }

            // tab, for easier open
            hull()
            {
                txy(guidler_mount_off)
                tx(guidler_mount_d/2)
                tz(extruder_b_guidler_screw_offset_h+guidler_screw_thread_dia/2 + 2*mm)
                rcylindera(d=guidler_w_, h=guidler_d, align=-X, orient=X);

                txy(guidler_mount_off)
                tx(guidler_mount_d/2)
                tz(extruder_b_guidler_screw_offset_h+guidler_screw_thread_dia/2 + 15*mm)
                rcylindera(d=guidler_w_, h=2*mm, align=-X, orient=X);
            }

            hull()
            {
                extruder_guidler(part="mainblock");

                txy(guidler_mount_off)
                tx(guidler_mount_d/2)
                tz(extruder_b_guidler_screw_offset_h+guidler_screw_thread_dia/2 + 2*mm)
                rcylindera(d=guidler_w_, h=guidler_d, align=-X, orient=X);
            }
        }
    }
    else if(part=="guidecut")
    {
        // guidler bearing cutout
        cylindera(d=extruder_drivegear_bearing_d+1.5*mm, h=100, orient=Y);

        // drive gear cutout
        tx(-extruder_drivegear_bearing_d/2)
        tx(-extruder_drivegear_d_outer/2)
        scale(1.10)
        extruder_drivegear(part="cutout");
    }
    else if(part=="neg")
    {
        // drive gear cutout
        tx(-extruder_drivegear_bearing_d/2)
        tx(-extruder_drivegear_d_outer/2)
        scale(1.10)
        extruder_drivegear(part="cutout");

        // guidler bearing cutout
        bearing_mount_bump = .6*mm;
        bearing_cut_w = extruder_drivegear_bearing_h+2*bearing_mount_bump;
        t(guidler_drivegear_offset)
        difference()
        {
            cylindera(d=extruder_drivegear_bearing_d+3*mm, h=bearing_cut_w, orient=Y);

            // add some bumps to avoid bearing grinding on walls
            for(y=[-1,1])
            ty(y*bearing_cut_w/2)
            ty(-y*bearing_mount_bump)
            mirror([0,max(0,y),0])
            cylindera(d2=extruder_drivegear_bearing_id+.8*mm, d1=guidler_bolt_mount_d, h=1, orient=Y, align=-Y);
        }

        t(guidler_drivegear_offset)
        if(extruder_drivegear_type == "Bondtech")
        {
            // guidler bearing/drivegear screw holder cutout
            hull()
            {
                cylindera(d=extruder_drivegear_bearing_id, h=extruder_drivegear_bearing_bolt_h, orient=Y);

                cubea([extruder_drivegear_bearing_id, extruder_drivegear_bearing_bolt_h, extruder_drivegear_bearing_id], align=-X);
            }
        }
        else
        {
            // guidler bearing/drivegear screw holder cutout
            ty(-guidler_w/2)
            ty(-1*mm)
            screw_cut(thread=extruder_drivegear_bearing_thread, head="button", head_embed=true, h=guidler_w, orient=Y, align=Y, with_nut_access=false);
        }

        // port hole to see bearing
        t(guidler_drivegear_offset)
        tx(extruder_drivegear_bearing_d/2)
        rcubea([guidler_mount_off.x+guidler_mount_d/2+.1*mm, extruder_drivegear_bearing_h+1*mm, extruder_drivegear_bearing_d/2+2*mm], align=X);

        // screw/spring for tighten
        t(extruder_guidler_screw_offset)
        tx(-8*mm)
        screw_cut(thread=guidler_screw_thread, nut=guidler_screw_nut, h=30*mm, orient=-X, align=X, nut_offset=6*mm);
    }
    else if(part=="vit")
    {
        if(extruder_drivegear_type == "Bondtech")
        {
            extruder_drivegear();

            // bearing bolt
            t(guidler_drivegear_offset)
            material(Mat_Chrome)
            cylindera(d=extruder_drivegear_bearing_id, h=extruder_drivegear_bearing_bolt_h, orient=Y);
        }
        else
        {
            t(guidler_drivegear_offset)
            bearing(extruder_drivegear_bearing, orient=Y);
        }
    }
    else if(part=="debug")
    {
        // filament path
        material(Mat_PlasticBlack)
        tx(-extruder_drivegear_bearing_d/2)
        tx(-filament_d/2)
        /*ty(-extruder_filament_bite)*/
        cylindera(d=filament_d, h=1000*mm, align=N);
    }
}

module sensormount(part=undef, align=N)
{
    if(part==U)
    {
        difference()
        {
            sensormount(part="pos", align=align);
            sensormount(part="neg", align=align);
        }
        if($show_vit)
        %sensormount(part="vit", align=align);
    }
    else if(part == "pos")
    material(Mat_Plastic)
    {
        rcubea(size=sensormount_size, align=Y);
    }
    else if(part == "neg")
    {
        /*cubea(s=[11,11,11]);*/
        ty(-14*mm)
        for(x=[-1,1])
        tx(x*5.5*mm)
        screw_cut(nut=NutKnurlM3_5_42, h=20*mm, with_nut=true, orient=Y, align=Y);
    }
    else if(part == "vit")
    {
        /*tz(8)*/
        /*rcubea(size=[17.8*mm,sensormount_thickness,35.7*mm], align=-Y-Z);*/

        color("darkgreen")
        translate([-8.8,0,8])
        rotate(X*90)
        rotate(Z*180)
        import("stl/SN04-N_Inductive_Proximity_Sensor_3528_0.stl");
    }
}

module e3d_heatsink_duct()
{
    hotend_heatsink_diameter = 25;
    hotend_heatsink_height = 32;
    hotend_heatsink_offset = 16; // offset off bottom of body that heatsink starts

    length = 55;
    width = 40;
    height = hotend_heatsink_offset+hotend_heatsink_height;

    fan_hole_dist = 32;
    m3_hexnut_dia = 6.4;
    m3_hexnut_flat_dia = 5.54;
    m3_hexnut_thickness = 2.4;

    difference() {
        union() {
            //cube([length, width, hotend_heatsink_offset+hotend_heatsink_height]);
            hull() {
                translate([0,0,20]) cube([20,40,height-20]);
                translate([50,5+17.5,height/2+20/2]) cube([5,30,height-20],center=true);
                translate([1,20,20]) rotate([0, 90, 0]) cylinder(r=38/2,h=1,center=true);
            }
        }

        // hotend heatsink hole
        translate([50, 5+17.75, hotend_heatsink_offset]) cylinder(r=hotend_heatsink_diameter/2, hotend_heatsink_height+1);
        translate([50, 5+17.75, 0]) cylinder(r=25/2, hotend_heatsink_offset+1);

        // first portion of fan duct
        difference() {
            hull() {
                translate([-1,20,20]) rotate([0, 90, 0]) cylinder(r=35/2,h=1,center=true);
                translate([50,5+17.5,24+25/2]) cube([20,20,20],center=true);
            }
            /*// support material ribs*/
            /*translate([0,12,0]) cube([length, 1, height]);*/
            /*translate([0,18,0]) cube([length, 1, height]);*/
            /*translate([0,23,0]) cube([length, 1, height]);*/
            /*translate([0,28,0]) cube([length, 1, height]);*/
        }

        // m3 traps for fan
        for (end = [-1,1]) {
            translate([-1,20+end*fan_hole_dist/2,20+fan_hole_dist/2]) rotate([0,90,0]) cylinder(r=1.6,h=30,center=true, $fn=7);
            translate([5,20+end*fan_hole_dist/2,20+fan_hole_dist/2]) rotate([0,90,0]) rotate([0,0,30]) cylinder(r=m3_hexnut_dia/2,h=m3_hexnut_thickness,center=true,$fn=6);
            translate([5-m3_hexnut_thickness/2,20+end*fan_hole_dist/2,20+fan_hole_dist/2]) rotate([end*-90,0,0]) translate([0,-m3_hexnut_flat_dia/2,0]) cube([m3_hexnut_thickness,m3_hexnut_flat_dia,10]);
        }

        if (1) {
            // clearance existing fan mounts
            cube([10,width,8]);

            // hole for clearance for wingnuts
            //translate([10,0,0]) cube([length-10,width+1,10]);

            translate([25, 5+17.75, 9]) cylinder(r=2.5, h=5, center=true);

        }
        else
        {
            // whatever. just get rid of everything for the bottom whatever mm
            //translate([-1,-1,-1]) cube([length+2,width+2,18+1]);
        }

        // clearance for bearing holder
        translate([18,0,0]) cube([40,5,25]);
        translate([10-3,0,0]) cube([50,9,6.5]);

        // TODO; clearance for extruder mounting bolt
    }
}

module part_x_carriage_left()
{
    rotate([0,0,180])
    rotate([90,0,0])
    x_carriage_withmounts(beltpath_sign=-1, with_sensormount=true);
}

module part_x_carriage_left_extruder_a()
{
    rotate([-90,0,0])
    extruder_a();
}

module part_x_carriage_left_extruder_b()
{
    rotate([-90,0,0])
    extruder_b();
}

module part_x_carriage_left_extruder_c()
{
    rotate([90,0,0])
    extruder_c();
}

module part_x_carriage_right()
{
    rotate([0,0,180])
    rotate([90,0,0])
    mirror(X)
    x_carriage_withmounts(beltpath_sign=1);
}

module part_x_carriage_right_extruder_a()
{
    rotate([-90,0,0])
    mirror(X)
    extruder_a();
}

module part_x_carriage_right_extruder_b()
{
    rotate([-90,0,0])
    mirror(X)
    extruder_b();
}

module part_x_carriage_right_extruder_c()
{
    rotate([90,0,0])
    mirror(X)
    extruder_c();
}

module part_x_carriage_extruder_guidler()
{
    guidler_conn_layflat = [ [guidler_mount_off.x+guidler_mount_d/2, 0, 0], X]; 
    attach([N,-Z], guidler_conn_layflat)
    {
        extruder_guidler();
    }
}

module part_x_carriage_extruder_filaguide()
{
    extruder_b_filaguide();
}


module x_carriage_full()
{
    x_carriage_withmounts();

    x_carriage_extruder();
}

module x_carriage_extruder(with_sensormount=false)
{
    $show_conn=false;
    $show_vit=true;
    debug_filapath=false;

    $explode=0;
    /*$explode=30*mm;*/
    /*$explode=50*mm;*/

    translate(extruder_offset)
    {
        te(extruder_offset_a, Y*$explode)
        extruder_a();

        te(extruder_offset_b+[0,-.1,0], Y*$explode)
        {
            difference()
            {
                union()
                {
                    extruder_b();

                    te(extruder_offset_b, Y*$explode)
                    t(extruder_b_hotend_mount_offset)
                    extruder_b_filaguide();

                    attach(extruder_conn_guidler, guidler_conn, extruder_guidler_roll, $explode=$explode/2)
                    extruder_guidler();

                    attach(extruder_b_hotend_mount_conn, hotend_conn, roll=0)
                    x_extruder_hotend();

                    te(extruder_offset_c, Y*$explode)
                    extruder_c();
                }

                if(debug_filapath)
                t(extruder_b_filapath_offset)
                cubea([1000,1000,1000], align=-Y);
            }
        }


        /*translate([explode[0],-explode[1],explode[2]])*/
        /*translate([-95,53,20])*/
        /*rotate([-152,0,0])*/
        /*import("stl/E3D_40_mm_Duct.stl");*/

        /*translate([explode[0],-explode[1],explode[2]])*/
        /*translate([-123.5,78.5,-54])*/
        /*rotate([0,0,-90])*/
        /*import("stl/E3D_30_mm_Duct.stl");*/

        /*translate(-extruder_offset)*/
        /*translate(34*X)*/
        /*translate(2*Y)*/
        /*translate(-1*Z)*/
        /*rotate(180*Z)*/
        /*rotate(-90*X)*/
        /*import("stl/Fan_Duct_V4.STL");*/

    }
}

module xaxis_end_bucket(part)
{
    s=[60,60,30];

    if(part==U)
    {
        difference()
        {
            xaxis_end_bucket(part="pos");
            xaxis_end_bucket(part="neg");
        }
    }
    else if(part=="pos")
    {
        tz(extruder_offset.z)
        tz(extruder_offset_b.z)
        tz(-hotend_height)
        t(extruder_b_hotend_mount_offset)

        tx(100)
        ty(extruder_b_filapath_offset.y)
        rcubea(size=s, align=-Z);
    }
    else if(part=="neg")
    {
        tz(extruder_offset.z)
        tz(extruder_offset_b.z)
        tz(-hotend_height)
        t(extruder_b_hotend_mount_offset)

        tx(100)
        ty(extruder_b_filapath_offset.y)
        rcubea(size=s-[3,3,3], align=-Z, extra_size=1000*Z, extra_align=Z);
    }
}

/*if(false)*/
{
    /*if(false)*/
    for(x=[-1])
    /*for(x=[-1,1])*/
    translate(x*40*mm*X)
    mirror([x<0?0:1,0,0])
    {
        x_carriage_withmounts(beltpath_sign=x, with_sensormount=x<0);

        x_carriage_extruder();

        /*translate(8*X)*/
        /*translate(-30*Y)*/
        /*translate(-33*Z)*/
        /*rotate(180*Y)*/
        /*rotate(-90*X)*/
        /*import("stl/e3d-v6-part-cooling-2x3510-blower.stl");*/
    }

    if(false)
    for(z=[-1,1])
    for(z=xaxis_beltpath_z_offsets)
    translate([-main_width/2, xaxis_carriage_beltpath_offset_y, z])
    rotate(90*X)
    belt_path(main_width, xaxis_belt_width, xaxis_pulley_inner_d, orient=X, align=X);

    if(false)
    for(x=[-1,1])
    translate([x*200,0,0])
    translate([0, xaxis_carriage_beltpath_offset_y, 0])
    mirror([max(0,x),0,0])
    {
        xaxis_end(with_motor=true, beltpath_index=max(0,x), show_motor=false, show_nut=false, show_bearings=false, with_xrod_adjustment=true);

        xaxis_end_bucket();
    }
}
