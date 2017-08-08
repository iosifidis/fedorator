$fn=80;

TOLERANCE = 0.5;

RPI_LENGTH = 85;
RPI_WIDTH = 56;
RPI_LEFT_PORTS_WIDTH = 2.5;
RPI_HEIGHT = 5;

RPI_HEIGHT_FULL = RPI_HEIGHT + 14;
RPI_LENGTH_FULL = RPI_LENGTH + TOLERANCE;
RPI_WIDTH_FULL = RPI_WIDTH + RPI_LEFT_PORTS_WIDTH + TOLERANCE;

//DISPLAY_HEIGHT = 5;
//DISPLAY_PIN_HEIGHT = 14;

//RPI_HEIGHT_WITH_DISPLAY = RPI_HEIGHT_FULL + DISPLAY_HEIGHT;

USB_PORT_HOLE=[40, 22, 12.5];
USB_PLUG_WITH_CABLE_LENGTH = 60;
USB_PORT_LENGTH = 8; // approx.
USP_PLUG_WIDTH = 30; // approx.
USB_PLUG_HEIGHT = 5; // approx.


RPI_DISPLAY_BOARD_DISTANCE = 8;
DISPLAY_BOARD_HEIGHT = 1;
DISPLAY_BOARD_LENGTH = 66;

// values from https://www.raspberrypi.org/documentation/hardware/display/7InchDisplayDrawing-14092015.pdf
DISPLAY_BASE_LENGTH = 164.9;
DISPLAY_BASE_WIDTH = 100.6;
DISPLAY_BASE_THICKNESS = 2.5;
DISPLAY_BASE_OFF_BOARD_X = 48.45; 
DISPLAY_BASE_OFF_BOARD_Y = DISPLAY_BASE_WIDTH - RPI_WIDTH - 20.8; 

DISPLAY_LENGTH = 192.96;
DISPLAY_WIDTH = 110.76;
DISPLAY_THICKNESS = 1.4;

SHELL_HEIGHT1 = 50;
SHELL_HEIGHT2 = 120 - SHELL_HEIGHT1;
SHELL_HEIGHT = SHELL_HEIGHT1 + SHELL_HEIGHT2;
SHELL_WIDTH = DISPLAY_WIDTH - 20;
SHELL_LENGTH = 130;
SHELL_THICKNESS = 3;

SHELL_ANGLE = -atan(SHELL_LENGTH/SHELL_HEIGHT2);
SHELL_TOP_LENGTH = sqrt(pow(SHELL_LENGTH, 2)+pow(SHELL_HEIGHT2,2));

/*RPI_POSITIONING = [(SHELL_WIDTH) / 2 - (RPI_WIDTH_FULL)/2,
                       0,
                       SHELL_TOP_LENGTH/6];
                       */
SHELL_TOP_TO_DISPLAY_BOTTOM = RPI_LENGTH * 1.2;
SHELL_BOTTOM_TO_DISPLAY = SHELL_TOP_LENGTH - SHELL_TOP_TO_DISPLAY_BOTTOM;
DISPLAY_POSITIONING = [(SHELL_WIDTH) / 2 - (RPI_WIDTH)/2,
                       0,
                       SHELL_TOP_LENGTH - SHELL_TOP_TO_DISPLAY_BOTTOM];



module prism(l, w, h){
    // from https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids
    polyhedron(
        points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
        faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
    );
}

/*module rpi_with_display_small() {
    // small display
    import("raspberry_pi_Bplus.STL", convexity=10);
    
    translate([0, RPI_LEFT_PORTS_WIDTH, RPI_HEIGHT+DISPLAY_PIN_HEIGHT])
        cube([RPI_LENGTH, RPI_WIDTH, DISPLAY_HEIGHT]);
    
    // double usb plug
    translate([RPI_LENGTH-USB_PORT_LENGTH, RPI_WIDTH-USP_PLUG_WIDTH, 13])
        cube([USB_PLUG_WITH_CABLE_LENGTH, USP_PLUG_WIDTH, USB_PLUG_HEIGHT]);
}*/


module display_anchor() {
    translate([0, 0, 3])
    cube([10, 5, 5], center=true);
}

module rpi_with_display() {
    translate([27, 47, 0]) // XXX
    translate([RPI_WIDTH_FULL, RPI_LENGTH, -RPI_DISPLAY_BOARD_DISTANCE])
    rotate([0, 180, 90]) {
        color("gray")
        import("raspberry_pi_Bplus.STL", convexity=10);
        
        // double usb plug
        translate([RPI_LENGTH-USB_PORT_LENGTH, RPI_WIDTH-USP_PLUG_WIDTH, 13])
            cube([USB_PLUG_WITH_CABLE_LENGTH, USP_PLUG_WIDTH, USB_PLUG_HEIGHT]);
        
        translate([0, RPI_LEFT_PORTS_WIDTH, -RPI_DISPLAY_BOARD_DISTANCE])
        {
         display();
        }
    }
}


module display() {
    cube([DISPLAY_BOARD_LENGTH, RPI_WIDTH, DISPLAY_BOARD_HEIGHT]);
        translate([-DISPLAY_BASE_OFF_BOARD_X, -DISPLAY_BASE_OFF_BOARD_Y, -DISPLAY_BASE_THICKNESS - 2])
        {
            cube([DISPLAY_BASE_LENGTH, DISPLAY_BASE_WIDTH, DISPLAY_BASE_THICKNESS]);
            
            
            x1 = 20.0;
            x2 = 20.0 + 126.2;
            y1 = DISPLAY_BASE_WIDTH + 6.63 - 21.58;
            y2 = DISPLAY_BASE_WIDTH + 6.63 - 21.58 - 65.65;
            
            translate([x1, y1, 0])
                display_anchor();
            translate([x2, y1, 0])
                display_anchor();
            translate([x1, y2, 0])
                display_anchor();
            translate([x2, y2, 0])
                display_anchor();
            
            translate([-11.89, -(DISPLAY_WIDTH - DISPLAY_BASE_WIDTH - 6.63), - 0.3])
            cube([DISPLAY_LENGTH, DISPLAY_WIDTH, DISPLAY_THICKNESS]);
        }
}

module rpid() {
    color("gray")
    translate([0,0,RPI_LENGTH])
    rotate([90,90,0])
        rpi_with_display();
}


module rounded_rect(size, radius) {
    x = size[0];
    y = size[1];
    hull() {
        for (xp = [0, 1]) {
            for (yp = [0, 1]) {
                translate([(xp*x)+(xp-0.5)*-2*(radius/2),
                           (yp*y)+(yp-0.5)*-2*(radius/2), 0])
                    circle(r=radius);
            }
        }
    }
}


module rounded_cube(size, radius, thickness) {
    x = size[0];
    y = size[1];
    z = size[2];

    linear_extrude(height=z)
        difference() {
            rounded_rect(size, radius);
            if(thickness != -1) {
                translate([thickness/2, thickness/2, 0])
                rounded_rect([size[0]-thickness, size[1]-thickness], radius);
            }
        }
}

module rpi_support_prism() {
    w = RPI_WIDTH/4;
    h = tan(90+SHELL_ANGLE)*RPI_LENGTH-RPI_HEIGHT;
    l = sqrt(pow(RPI_LENGTH, 2) - pow(h, 2));
    prism(w,
        l,
        h);
    
    translate([0, 0, -SHELL_HEIGHT1])
        cube([w, l/5, SHELL_HEIGHT1]);
    
    translate([0, l - l/5, -SHELL_HEIGHT1])
        cube([w, l/5, SHELL_HEIGHT1]);
}

module rpi_support() {
    rpi_support_prism();
    translate([RPI_WIDTH - RPI_WIDTH/4, 0, 0])
        rpi_support_prism();
}


module shell() {
    //rounded_cube([SHELL_WIDTH, SHELL_LENGTH, SHELL_HEIGHT1], SHELL_THICKNESS, SHELL_THICKNESS);
    difference() {
        difference() {
            minkowski() {
                prism(SHELL_WIDTH, SHELL_LENGTH, SHELL_HEIGHT2);
                cylinder(r=SHELL_THICKNESS,h=SHELL_HEIGHT1+SHELL_THICKNESS);
            }
            translate([0, 0, SHELL_THICKNESS])
            minkowski() {
                prism(SHELL_WIDTH, SHELL_LENGTH, SHELL_HEIGHT2);
                cylinder(r=1,h=SHELL_HEIGHT1);
            }
        }
        // holes
        union() {
            // hole for display
            translate([0, 0, SHELL_HEIGHT1+SHELL_THICKNESS*2])
            rotate([SHELL_ANGLE, 0, 0])
            translate([-TOLERANCE, 0, -TOLERANCE])
                cube([SHELL_WIDTH,
                    SHELL_THICKNESS,
                    SHELL_TOP_LENGTH]);
            
            // hole for usb port
            translate([(SHELL_WIDTH) / 2 - (USB_PORT_HOLE[0])/2,
                    -SHELL_THICKNESS,
                    SHELL_HEIGHT1/2-USB_PORT_HOLE[2]])
                cube(USB_PORT_HOLE);
            
            // we'll do without the back wall
            
            translate([0, SHELL_LENGTH, 0])
            cube([SHELL_WIDTH, SHELL_THICKNESS, SHELL_HEIGHT]);
        }
    }
    translate([-SHELL_THICKNESS/4, SHELL_LENGTH-SHELL_THICKNESS/2, SHELL_HEIGHT-SHELL_THICKNESS+SHELL_THICKNESS])
        cube([SHELL_WIDTH+SHELL_THICKNESS/2, SHELL_THICKNESS, SHELL_THICKNESS]);
    
    translate([0, 0, SHELL_HEIGHT1])
    minkowski() {
        cube([SHELL_WIDTH, 1, SHELL_HEIGHT1*0.2]);
        cylinder(r=SHELL_THICKNESS,h=0.001);
    }
}


//translate(DISPLAY_POSITIONING)
//translate([-RPI_LEFT_PORTS_WIDTH, 0, RPI_LENGTH])
//

//translate([0, -SHELL_BOTTOM_TO_DISPLAY*sin(SHELL_ANGLE), SHELL_BOTTOM_TO_DISPLAY*cos(SHELL_ANGLE)])
//translate([0, 0, SHELL_HEIGHT1+SHELL_THICKNESS])
//rotate([SHELL_ANGLE, 0, 0])
//translate([0, 0, RPI_LENGTH])
//rotate([90, 90, 0])

translate([SHELL_WIDTH / 2 - DISPLAY_WIDTH/2, 0, 0])
translate([0, 0, SHELL_HEIGHT1+SHELL_THICKNESS])
rotate([90+SHELL_ANGLE, 0, 0])
%rpi_with_display();


translate([200, 0, 0])// -RPI_HEIGHT_WITH_DISPLAY])
%rpi_with_display();


FRONT_TO_RPI = 50;
GROUND_TO_RPI =
    SHELL_HEIGHT
    - (SHELL_TOP_TO_DISPLAY_BOTTOM / SHELL_TOP_LENGTH) * SHELL_HEIGHT2
    - (SHELL_LENGTH/SHELL_TOP_LENGTH)*RPI_HEIGHT_WITH_DISPLAY;

/*
translate([(SHELL_WIDTH) / 2 - (RPI_WIDTH)/2,
    FRONT_TO_RPI,
    GROUND_TO_RPI])
rpi_support();*/

shell();
/*
difference() {
    shell();
    union() {
        translate([-10, 0, -10])
        cube([200, 200, 200]);
        translate([-10, -10, 20])
        cube([200, 200, 200]);
    }
}
*/