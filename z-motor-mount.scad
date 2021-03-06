include <z-motor-mount.h>
include <thing_libutils/materials.scad>
include <thing_libutils/stepper.scad>

use <thing_libutils/attach.scad>
use <thing_libutils/shapes.scad>
use <thing_libutils/screws.scad>
use <thing_libutils/transforms.scad>
use <thing_libutils/stepper.scad>

use <rod-clamps.scad>


module zaxis_motor_mount(part)
{
    if(part==U)
    {
        difference()
        {
            zaxis_motor_mount(part="pos");
            zaxis_motor_mount(part="neg");
        }
        if($show_vit)
        zaxis_motor_mount(part="vit");
    }
    else if(part=="pos")
    material(Mat_Plastic)
    {
        // top plate
        rcubea([zmotor_w+zmotor_mount_thickness, zmotor_w+zmotor_mount_thickness*2, zmotor_mount_thickness_h], align=X+Z);

        // reinforcement plate between motor and extrusion
        rcubea([zmotor_mount_thickness, zmotor_w+2, zmotor_h], align=X-Z, extra_size=[0,0,2], extra_align=Z);

        // top extrusion mount plate
        translate([0, 0,-extrusion_size-zaxis_motor_offset_z])
        rcubea([zmotor_mount_thickness, zmotor_mount_width, extrusion_size], align=X+Z);

        // bottom extrusion mount plate
        translate([0, 0, -main_lower_dist_z-extrusion_size-zaxis_motor_offset_z])
        rcubea([zmotor_mount_thickness, zmotor_w+2, extrusion_size], align=X+Z);

        // side triangles
        for(i=[-1,1])
        {
            translate([zmotor_mount_thickness, i*((zmotor_w/2)+zmotor_mount_thickness/2), 2])
            triangle(
                zmotor_w,
                main_lower_dist_z+extrusion_size+zaxis_motor_offset_z+2,
                depth=zmotor_mount_thickness,
                align=X-Z,
                orient=X
                );

            translate([0, i*((zmotor_w/2)+zmotor_mount_thickness/2), 2])
            cubea([zmotor_mount_thickness, zmotor_mount_thickness, zmotor_mount_h+2], align=X-Z);
        }

        attach([[get(NemaSideSize,zaxis_motor)/2,0,0],N],zmotor_mount_conn_motor)
        motor_mount(part=part, model=zaxis_motor, thickness=zmotor_mount_thickness_h);
    }
    else if(part=="neg")
    {
        // cutout for motor cables
        translate([0,0,-30*mm])
        cubea([zmotor_mount_thickness*3, 20*mm, zmotor_h], align=-Z);

        // screw holes top
        for(y=[-1,1])
        tx(zmotor_mount_thickness)
        ty(y*(zmotor_w/2+zmotor_mount_thread_dia*3))
        tz(-extrusion_size)
        screw_cut(nut=extrusion_nut, head="button", h=12*mm, orient=-X, align=-X);

        // screw hole bottom
        for(y=[0])
        tx(zmotor_mount_thickness)
        ty(y*(zmotor_w/2+zmotor_mount_thread_dia*3))
        tz(-extrusion_size-main_lower_dist_z)
        screw_cut(nut=extrusion_nut, head="button", h=12*mm, orient=-X, align=-X);

        // cut out z rod
        tx(zmotor_mount_rod_offset_x)
        cylindera(d=zaxis_rod_d*rod_fit_tolerance, h=100, orient=Z);
    }
    else if(part=="vit")
    {
    }

    attach([[get(NemaSideSize,zaxis_motor)/2,0,0],N],zmotor_mount_conn_motor)
    motor_mount(part=part, model=zaxis_motor, thickness=zmotor_mount_thickness_h);
}

module part_z_motor_mount()
{
    rotate([0,-90,0])
    zaxis_motor_mount();
}

if(false)
zaxis_motor_mount();

