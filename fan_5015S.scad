include <thing_libutils/system.scad>
include <thing_libutils/units.scad>
use <thing_libutils/shapes.scad>;

fan_5015S_screwpos = [[-20.15*mm,20.3*mm],[22*mm, -19.5*mm]];
fan_5015S_X = 51.2;
fan_5015S_Y = 51.2;
fan_5015S_Z = 15;
fan_5015S_output_X = 19;
fan_5015S_output_Y = 11;
fan_5015S_output_screw_Y = -6.5;
fan_5015S_output_screw_X = 9.5;

fan_5015S();

/*translate([0,0,-10])*/
/*fan_5015S_bracket();*/

//optional 5015S fan_5015S fan mockup
module fan_5015S(part)
{
    if(part==undef)
    {
        difference()
        {
            fan_5015S(part="pos");
            fan_5015S(part="neg");
        }
    }
    else if(part=="pos")
    {
        translate([0, -fan_5015S_output_Y, 0])
        cube([fan_5015S_output_X, fan_5015S_output_Y+fan_5015S_Y/2, fan_5015S_Z]);

        cylindera(r=fan_5015S_X/2, h=fan_5015S_Z, align=[1,1,1]);
        translate([fan_5015S_X/2, fan_5015S_Y/2, 0])
        union()
        {
            hull()
            {
                for(pos=fan_5015S_screwpos)
                translate([pos[0], pos[1], 0])
                cylindera(d=8*mm, h=fan_5015S_Z, align=Z);
            }
        }
    }
    else if(part=="neg")
    {
        translate([fan_5015S_X/2, fan_5015S_Y/2, 0])
        union()
        {
            for(pos=fan_5015S_screwpos)
            translate([pos[0], pos[1], 0])
            cylindera(d=3.3*mm, h=fan_5015S_Z+.1, align=Z);
        }
    }
}


// fan_5015S mounting plate
module fan_5015S_bracket(thickness=2.2*mm)
{
    linear_extrude(thickness)
    projection(cut=false)
    fan_5015S();
}



