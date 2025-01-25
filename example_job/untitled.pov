// ***********************************************************
// Persistence Of Vision Ray Tracer Scene Description File
// File name  : poolballs.pov
// Version    : 3.7
// Description: Earth and moon
// Date       : 2024-11-13
// Author     : Bryce Lobdell
// ***********************************************************
#version 3.7;

// *** standard includes ***
#include "colors.inc"
#include "textures.inc"
#include "functions.inc"
#include "rad_def.inc"

#include "before_include.inc"


#declare earth_moon_distance_km = 384.4e2; // This is in kilometers
#declare earth_radius_km = 12.742e3/2;
#declare moon_radius_km = 3474.8/2;


#declare D = .15;

sky_sphere {
        pigment {
                crackle
                color_map {
                        [pow(0.5, D) color Black]
                        [pow(0.6, D) color White*10]
                }
                scale .0005/D
        }
}


/*
camera {
    location <0,0,0 >
    angle 90
    look_at  <earth_radius_km*8, earth_radius_km*8,  0>
}
*/


camera {
   location <earth_radius_km*3, -earth_radius_km*4,-earth_radius_km*15>
   up y
   right -x*image_width/image_height
   angle 60
   // sky <0,0,1>
   look_at <0,0,0>
}   



light_source { <earth_radius_km*8, earth_radius_km*8, 0 > color White}


sphere {
    <0, 0, 0>, earth_radius_km

    

    texture {
      pigment { 
        // color rgb <0.3,0.3,1.0> 

        image_map {
            jpeg "1920px-Lambert_cylindrical_equal-area_projection_SW.jpg" // one of the accepted file formats
            map_type 1 // this is spherical wrapping

            
        }

      }

      rotate <0, earth_rotate_angle , 0>
    }

    finish {
      ambient rgb <0.15,0.15,0.15>
    }
}



/*
red x, green y, blue z

 camera at 1,1,0
 red at 1,0,0
 green at 0,1,0
 blue at 0,0,1
*/

/*
sphere {
    <0, earth_moon_distance_km, 0>, moon_radius_km
    texture {
      pigment { 
        color Green 
      }
    }

    finish {
      ambient rgb <0.25,0.25,0.25>
    }
}

sphere {
    <earth_moon_distance_km, 0, 0>, moon_radius_km
    texture {
      pigment { 
        color Red 
      }
    }

    finish {
      ambient rgb <0.25,0.25,0.25>
    }
}

sphere {
    <0, 0, earth_moon_distance_km>, moon_radius_km
    texture {
      pigment { 
        color LightBlue 
      }
    }

    finish {
      ambient rgb <0.25,0.25,0.25>
    }
}
*/


#include "after_include.inc"